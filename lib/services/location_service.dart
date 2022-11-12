import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  static late Position? initialPosition;
  Position? currentPosition;

  static bool isPermissionEnabled = false;
  StreamSubscription<Position>? positionStream;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  LocationService() {
    currentPosition = initialPosition;

    if (!isPermissionEnabled) {
      return;
    }

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.enabled) {
        positionStream ??= Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            currentPosition = position;
            notifyListeners();
          },
          onError: handleError,
          cancelOnError: false,
        );
      } else {
        positionStream = null;

        currentPosition = null;
        notifyListeners();
      }
    });
  }

  void handleError(Object object, StackTrace st) {
    currentPosition = null;
    notifyListeners();
  }

  String getDistance(double endLatitude, double endLongitude) {
    if (currentPosition == null) {
      return "N/A";
    }

    double distanceInMeters =
        Geolocator.distanceBetween(currentPosition!.latitude, currentPosition!.longitude, endLatitude, endLongitude);

    if (distanceInMeters > 1000) {
      return "${(distanceInMeters / 1000).toStringAsFixed(1)}km";
    } else {
      return "${(distanceInMeters / 10).toStringAsFixed(0)}m";
    }
  }

  static Future<void> init() async {
    try {
      await checkPermission();

      initialPosition = await Geolocator.getCurrentPosition();
    } catch (_) {
      initialPosition = null;
    }
  }

  static Future<void> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    isPermissionEnabled = true;
  }
}
