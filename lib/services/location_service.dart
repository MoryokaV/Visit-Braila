import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  static late Position? initialPosition;
  Position? currentPosition;

  static bool isPermissionEnabled = false;
  static bool initialServiceEnabled = false;

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

    if (initialServiceEnabled) {
      listenLocationService();
    }

    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.enabled) {
        listenLocationService();
      } else {
        if (positionStream != null) {
          positionStream!.cancel();
        }

        currentPosition = null;
        notifyListeners();
      }
    });
  }

  void listenLocationService() {
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        currentPosition = position;
        notifyListeners();
      },
      onError: handleError,
      cancelOnError: false,
    );
  }

  void handleError(Object _, StackTrace __) {
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
      return "${(distanceInMeters / 10).toStringAsFixed(0)}0m";
    }
  }

  static Future<void> init() async {
    try {
      await checkPermission();
      await checkServiceStatus();

      initialPosition = await Geolocator.getLastKnownPosition();
    } catch (_) {
      initialPosition = null;
    }
  }

  static Future<void> checkServiceStatus() async {
    initialServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!initialServiceEnabled) {
      return Future.error('Location service is disabled');
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
