import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/services/navigation_service.dart';

class DeepLinkService {
  static const platform = MethodChannel("city.visit.braila");
  static const stream = EventChannel("city.visit.braila/incomingRedirects");

  static final StreamController<String> _streamController = StreamController();

  DeepLinkService() {
    startUrl();

    stream.receiveBroadcastStream().listen((d) {
      onRedirected(d);
    });
  }

  static init() {
    startUrl();

    stream.receiveBroadcastStream().listen((d) {
      onRedirected(d);
    });
  }

  static void onRedirected(String url) {
    _streamController.sink.add(url);

    handleRouteRedirection(Uri.parse(url));
  }

  static Future<void> startUrl() async {
    try {
      String? url = await platform.invokeMethod('initialLink');

      if (url == null) {
        return;
      }

      onRedirected(url);
    } catch (_) {
      return;
    }
  }

  static void redirect(String route, arguments) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService.navigateToWithArguments(route, arguments);
    });
  }

  static void handleRouteRedirection(Uri uri) async {
    switch (uri.pathSegments.first) {
      case 'sight':
        String? id = uri.queryParameters['id'];
        
        if (id == null) {
          return;
        }

        redirect('/sight', await SightController().findSight(id));
        break;
      case 'tour':
        String? id = uri.queryParameters['id'];

        if(id == null){
          return;
        }

        redirect('/tour', await TourController().findTour(id));
        break;
      default:
        return;
    }
  }
}
