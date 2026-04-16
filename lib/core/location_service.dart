import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class AppLocation {
  final double latitude;
  final double longitude;
  final bool isFallback;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.isFallback = false,
  });
}

class LocationService {
  static const fallbackLat = 28.4595;
  static const fallbackLng = 77.0266;

  static Future<AppLocation> getCurrentOrFallbackLocation() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        debugPrint("[LocationService] Location service disabled, using fallback");
        return _fallback();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint(
          "[LocationService] Location permission unavailable ($permission), using fallback",
        );
        return _fallback();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint(
        "[LocationService] Device location resolved lat=${position.latitude}, lng=${position.longitude}",
      );

      return AppLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint("[LocationService] Failed to resolve location: $e");
      return _fallback();
    }
  }

  static AppLocation _fallback() {
    return const AppLocation(
      latitude: fallbackLat,
      longitude: fallbackLng,
      isFallback: true,
    );
  }
}
