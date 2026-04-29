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

  static Future<AppLocation> getCurrentLocation() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception('Location service is disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission denied forever. Please enable it from settings.',
      );
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      position = await Geolocator.getLastKnownPosition();
    }

    if (position == null) {
      throw Exception('Unable to fetch current location. Please try again.');
    }

    debugPrint(
      "[LocationService] Device current location resolved lat=${position.latitude}, lng=${position.longitude}",
    );

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  static Future<AppLocation> getCurrentOrFallbackLocation() async {
    try {
      return await getCurrentLocation();
    } catch (e) {
      debugPrint("[LocationService] Failed to resolve location: $e");
      return _fallback();
    }
  }

  static Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  static Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  static AppLocation _fallback() {
    return const AppLocation(
      latitude: fallbackLat,
      longitude: fallbackLng,
      isFallback: true,
    );
  }
}
