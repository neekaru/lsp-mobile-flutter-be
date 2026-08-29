import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocode_cache/geocode_cache.dart';
import 'package:geocoding/geocoding.dart' as native_geo;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class UserGeoLocation {
  final double latitude;
  final double longitude;
  final String locationName;

  const UserGeoLocation({
    required this.latitude,
    required this.longitude,
    this.locationName = 'Lokasi Saya',
  });
}

class LocationService {
  static const String _defaultApiKey =
      'AIzaSyA9i8FJTM8skspMB5DueA4rcv5RVSlXpsM';

  static String get apiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key != null && key.isNotEmpty) return key;
    return _defaultApiKey;
  }

  // Default fallback center: Jakarta (DKI Jakarta)
  static const double defaultLat = -6.2088;
  static const double defaultLng = 106.8456;

  static bool _cacheInitialized = false;

  static Future<void> _ensureCacheInit() async {
    if (!_cacheInitialized) {
      try {
        GeocodingService.instance.configure(
          options: const GeocodeCacheOptions(
            cacheRadiusMeters: 50.0,
            maxAge: Duration(days: 7),
          ),
        );
      } catch (_) {}
      try {
        await GeocodingService.instance.init();
        _cacheInitialized = true;
      } catch (_) {}
    }
  }

  /// Request GPS permission and get current device position with native GPS & Jakarta fallback
  static Future<UserGeoLocation> getCurrentLocation() async {
    double lat = 0.0;
    double lng = 0.0;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) debugPrint('⚠️ GPS Location service is disabled on device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) debugPrint('⚠️ Location permission permanently denied.');
      }

      Position? position;

      // 1. Try instant cached last known position first (1ms fast fix)
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      // 2. Try active live GPS satellite/network position
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              timeLimit: Duration(seconds: 10),
            ),
          );
        } catch (_) {
          // 3. Fallback to medium accuracy / Wi-Fi / cell tower
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 6),
              ),
            );
          } catch (_) {}
        }
      }

      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error reading GPS: $e');
    }

    // If GPS is unavailable/denied, fallback to Jakarta
    if (lat == 0.0 && lng == 0.0) {
      lat = defaultLat;
      lng = defaultLng;
    }

    // Resolve real city name via GeocodingService (geocode_cache) + Native Android/iOS Geocoder or Google Maps API
    final realName = await getRealLocationName(lat, lng);
    if (kDebugMode) {
      debugPrint('📍 Geocoded Location resolved: $lat, $lng ($realName)');
    }

    return UserGeoLocation(
      latitude: lat,
      longitude: lng,
      locationName: realName,
    );
  }

  /// Resolve exact City / Kabupaten using geocode_cache + Native OS Geocoder + Google Maps fallback
  static Future<String> getRealLocationName(double lat, double lng) async {
    // 1. geocode_cache (GeocodingService) with 50m radius caching to save API calls
    try {
      await _ensureCacheInit();
      final place = await GeocodingService.instance
          .getPlacemarkFromCoordinates(lat, lng);
      if (place != null) {
        final locality = place.locality;
        final subAdmin = place.subAdministrativeArea;
        final admin = place.administrativeArea;

        if (locality != null && locality.isNotEmpty) {
          return subAdmin != null && subAdmin.isNotEmpty
              ? '$locality, $subAdmin'
              : locality;
        }
        if (subAdmin != null && subAdmin.isNotEmpty) {
          return subAdmin;
        }
        if (admin != null && admin.isNotEmpty) {
          return admin;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ GeocodingService cache fallback: $e');
    }

    // 2. Direct native_geo fallback
    try {
      final placemarks = await native_geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locality = place.locality;
        final subAdmin = place.subAdministrativeArea;
        final admin = place.administrativeArea;

        if (locality != null && locality.isNotEmpty) {
          return subAdmin != null && subAdmin.isNotEmpty
              ? '$locality, $subAdmin'
              : locality;
        }
        if (subAdmin != null && subAdmin.isNotEmpty) {
          return subAdmin;
        }
        if (admin != null && admin.isNotEmpty) {
          return admin;
        }
      }
    } catch (_) {}

    // 3. Official Google Maps Geocoding API Fallback
    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&language=id&key=$apiKey';
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final status = data['status']?.toString();

        if (status == 'OK') {
          final results = data['results'] as List<dynamic>? ?? [];
          for (final res in results) {
            final components =
                res['address_components'] as List<dynamic>? ?? [];

            String? locality;
            String? subAdmin;
            String? admin;

            for (final comp in components) {
              final types = (comp['types'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];
              if (types.contains('locality') ||
                  types.contains('administrative_area_level_3')) {
                locality = comp['long_name']?.toString();
              }
              if (types.contains('administrative_area_level_2')) {
                subAdmin = comp['long_name']?.toString();
              }
              if (types.contains('administrative_area_level_1')) {
                admin = comp['long_name']?.toString();
              }
            }

            if (locality != null && locality.isNotEmpty) {
              return locality;
            }
            if (subAdmin != null && subAdmin.isNotEmpty) {
              return subAdmin;
            }
            if (admin != null && admin.isNotEmpty) {
              return admin;
            }
          }

          if (results.isNotEmpty) {
            final firstAddr =
                results.first['formatted_address']?.toString() ?? '';
            final parts = firstAddr.split(',');
            if (parts.length > 1) {
              return parts[parts.length - 3].trim();
            }
          }
        }
      }
    } catch (_) {}

    return 'Lokasi Saya (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
  }

  /// Calculate distance in meters between two coordinates
  static double distanceInMeters(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Calculate distance in kilometers between two coordinates
  static double distanceBetween(
      double startLat, double startLng, double endLat, double endLng) {
    return distanceInMeters(startLat, startLng, endLat, endLng) / 1000.0;
  }
}
