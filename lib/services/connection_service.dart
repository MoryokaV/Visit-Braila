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
      isOnline = checkConnectivity(status);

      if (!isOnline && !popup) {
        NavigationUtil.navigateTo('/nointernet');
      }

      notifyListeners();
    });
  }

  static Future<void> init() async {
    initialConnectionStatus = checkConnectivity(await Connectivity().checkConnectivity());
  }

  static bool checkConnectivity(List<ConnectivityResult> connectivity) {
    if (!connectivity.contains(ConnectivityResult.mobile) && !connectivity.contains(ConnectivityResult.wifi)) {
      return false;
    }

    return true;
  }
}
