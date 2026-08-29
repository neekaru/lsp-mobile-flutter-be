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
  // Default fallback center if GPS is completely unavailable (Sampit / Central point)
  static const double defaultLat = -2.5360;
  static const double defaultLng = 112.9540;

  /// Request GPS permission and get current device position with multi-tier fallback
  static Future<UserGeoLocation> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) debugPrint('⚠️ GPS Location service is disabled on device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (kDebugMode) debugPrint('⚠️ Location permission denied.');
        // Try to get last known position even with coarse permission
      }

      // Step 1: Try getting instant last known position
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      // Step 2: Try getting active GPS position
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              timeLimit: Duration(seconds: 12),
            ),
          );
        } catch (e) {
          // Retry with lower accuracy for fast indoor / cell-tower fix
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 8),
              ),
            );
          } catch (_) {}
        }
      }

      if (position != null) {
        final region = _detectRegionName(position.latitude, position.longitude);
        return UserGeoLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          locationName: region,
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error getting current position: $e');
    }

    // Default fallback to Sampit / Kotim
    return const UserGeoLocation(
      latitude: defaultLat,
      longitude: defaultLng,
      locationName: 'Sampit (Default)',
    );
  }

  static String _detectRegionName(double lat, double lng) {
    if (lat < -1.0 && lat > -4.5 && lng > 111.0 && lng < 116.0) {
      return 'Sampit / Kalteng';
    } else if (lat < -7.0 && lat > -8.5 && lng > 109.5 && lng < 111.5) {
      return 'DI Yogyakarta';
    } else if (lat < -6.0 && lat > -7.5 && lng > 106.0 && lng < 108.0) {
      return 'Jabodetabek / Jabar';
    } else if (lat < -6.5 && lat > -8.5 && lng > 111.5 && lng < 115.0) {
      return 'Jawa Timur';
    } else if (lat < -6.5 && lat > -8.0 && lng > 108.5 && lng < 111.5) {
      return 'Jawa Tengah';
    }
    return 'Lokasi Saya (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
  }

  /// Calculate distance in kilometers between two coordinates
  static double distanceBetween(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000.0;
  }
}
