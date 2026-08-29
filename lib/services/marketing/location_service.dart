import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

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
  // Default fallback center (Yogyakarta) if GPS disabled / permission denied
  static const double defaultLat = -7.7956;
  static const double defaultLng = 110.3695;

  /// Request GPS permission and get current device position
  static Future<UserGeoLocation> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) debugPrint('⚠️ Location services are disabled.');
        return const UserGeoLocation(
          latitude: defaultLat,
          longitude: defaultLng,
          locationName: 'DI Yogyakarta (Default)',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) debugPrint('⚠️ Location permissions are denied.');
          return const UserGeoLocation(
            latitude: defaultLat,
            longitude: defaultLng,
            locationName: 'DI Yogyakarta (Default)',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          debugPrint('⚠️ Location permissions are permanently denied.');
        }
        return const UserGeoLocation(
          latitude: defaultLat,
          longitude: defaultLng,
          locationName: 'DI Yogyakarta (Default)',
        );
      }

      // Get accurate GPS location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Simple heuristic region label
      String region = 'Lokasi Saya';
      if (position.latitude < -1.0 &&
          position.latitude > -4.0 &&
          position.longitude > 111.0 &&
          position.longitude < 115.0) {
        region = 'Kotawaringin Timur (Sampit)';
      } else if (position.latitude < -7.0 &&
          position.latitude > -8.5 &&
          position.longitude > 109.5 &&
          position.longitude < 111.5) {
        region = 'DI Yogyakarta';
      }

      return UserGeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: region,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error getting current position: $e');
      return const UserGeoLocation(
        latitude: defaultLat,
        longitude: defaultLng,
        locationName: 'DI Yogyakarta (Default)',
      );
    }
  }

  /// Calculate distance in kilometers between two coordinates
  static double distanceBetween(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000.0;
  }
}

