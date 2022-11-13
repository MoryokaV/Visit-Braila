import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/services/navigation_service.dart';

class ConnectionService extends ChangeNotifier {
  final Duration interval = const Duration(seconds: 3);
  
  static late bool initialConnectionStatus;
  late bool isOnline;
  bool popup = false;

  ConnectionService() {
    isOnline = initialConnectionStatus;

    if (!isOnline) {
      popup = true;
    }

    InternetConnectionChecker.createInstance(
      checkInterval: interval,
      checkTimeout: interval,
    ).onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        isOnline = true;
      } else {
        isOnline = false;
        if (!popup) {
          NavigationService.navigateTo('/nointernet');
        }
      }

      notifyListeners();
    });
  }

  static Future<void> init() async {
    initialConnectionStatus = await InternetConnectionChecker().hasConnection;
  }
}
