import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();
  // Start realtime tracking
  Stream<Position> getTrackingStream() async* {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS tidak aktif");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Permission ditolak permanen");
    }
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, 
      intervalDuration: const Duration(seconds: 10),
      forceLocationManager: true,

      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "Tracking lokasi aktif",
        notificationTitle: "Driver Tracking",
        enableWakeLock: true,
      ),
    );

    yield* Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  //get location 1 kali
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("GPS tidak aktif");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Permission ditolak permanen");
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
      )
    );
  }
}