import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  /// Request GPS permission and get current device position with accurate reverse geocoding
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

      // 1. Try active high accuracy GPS first
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        // Fallback to last known position
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }

      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error reading GPS: $e');
    }

    // If still 0, fallback to standard Sampit coordinates
    if (lat == 0.0 && lng == 0.0) {
      lat = -2.5360;
      lng = 112.9540;
    }

    // Pure dynamic reverse geocoding to get real city/kabupaten name (No hardcoded boundaries)
    final realName = await getRealLocationName(lat, lng);

    return UserGeoLocation(
      latitude: lat,
      longitude: lng,
      locationName: realName,
    );
  }

  /// Pure dynamic reverse geocoding to resolve exact city / kabupaten
  static Future<String> getRealLocationName(double lat, double lng) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'LSPDigitalMobile/1.2 (asesor@lsp-digital.id)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final name = address['city']?.toString() ??
              address['town']?.toString() ??
              address['county']?.toString() ??
              address['municipality']?.toString() ??
              address['city_district']?.toString() ??
              address['village']?.toString() ??
              address['state']?.toString();
          if (name != null && name.isNotEmpty) {
            return name;
          }
        }
      }
    } catch (_) {}
    return 'Lokasi Saya (${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
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
