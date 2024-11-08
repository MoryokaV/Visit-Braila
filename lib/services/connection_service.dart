import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/utils/navigation_util.dart';

class ConnectionService extends ChangeNotifier {
  static late bool initialConnectionStatus;
  late bool isOnline;
  bool popup = false;

  ConnectionService() {
    isOnline = initialConnectionStatus;

    if (!isOnline) {
      popup = true;
    }

    Connectivity().onConnectivityChanged.listen((status) {
      print(status); //TODO: Check breaking changes on Android platform
      // isOnline = checkConnectivity(status);
      isOnline = true;

      if (!isOnline && !popup) {
        NavigationUtil.navigateTo('/nointernet');
      }

      notifyListeners();
    });
  }

  static Future<void> init() async {
    // initialConnectionStatus = checkConnectivity(await Connectivity().checkConnectivity());
  }

  static bool checkConnectivity(ConnectivityResult connectivity) {
    if (connectivity != ConnectivityResult.mobile && connectivity != ConnectivityResult.wifi) {
      return false;
    }

    return true;
  }
}
