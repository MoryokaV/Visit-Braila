import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/utils/navigation_util.dart';

const Duration kInterval = Duration(seconds: 3);

class ConnectionService extends ChangeNotifier {
  static late bool initialConnectionStatus;
  late bool isOnline;
  bool popup = false;

  ConnectionService() {
    isOnline = initialConnectionStatus;

    if (!isOnline) {
      popup = true;
    }

    InternetConnectionChecker.createInstance(
      checkInterval: kInterval,
    ).onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        isOnline = true;
      } else {
        isOnline = false;
        if (!popup) {
          NavigationUtil.navigateTo('/nointernet');
        }
      }

      notifyListeners();
    });
  }

  static Future<void> init() async {
    initialConnectionStatus = await InternetConnectionChecker().hasConnection;
  }
}
