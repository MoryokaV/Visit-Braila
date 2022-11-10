import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/services/navigation_service.dart';

class ConnectionService extends ChangeNotifier {
  static late bool initialConnectionStatus;
  late bool isOnline;
  bool block = false;

  ConnectionService() {
    isOnline = initialConnectionStatus;

    Connectivity().onConnectivityChanged.listen((result) {
      isOnline = checkConnectivity(result);
      notifyListeners();

      if (!isOnline && !block) {
        NavigationService.navigateTo('/nointernet');
        block = true;
      }
    });
  }

  static Future<void> init() async {
    initialConnectionStatus = checkConnectivity(await Connectivity().checkConnectivity());
  }

  static bool checkConnectivity(ConnectivityResult connectivity) {
    if (connectivity != ConnectivityResult.mobile && connectivity != ConnectivityResult.wifi) {
      return false;
    }

    return true;
  }
}
