import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/services/navigation_service.dart';

const String uriPrefix = "https://visitbraila.page.link";
const String customDomain = "https://visitbraila.ro";

class DeepLinkService {
  static bool initialLinkGathered = false;

  static Future<Uri> generateDynamicLink({
    required String id,
    required String image,
    required String name,
    required String collection,
    required String alternativeUrl,
  }) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("$customDomain/$collection?id=$id"),
      uriPrefix: uriPrefix,
      androidParameters: AndroidParameters(
        fallbackUrl: Uri.parse(alternativeUrl),
        packageName: "com.vmasoftware.visit_braila",
      ),
      iosParameters: IOSParameters(
        bundleId: "com.vmasoftware.visitBraila",
        fallbackUrl: Uri.parse(alternativeUrl),
      ),
      navigationInfoParameters: const NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: name,
        imageUrl: Uri.parse(image),
      ),
    );

    final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
      dynamicLinkParams,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    return dynamicLink.shortUrl;
  }

  static init() {
    startUrl();

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      handleRouteRedirection(dynamicLinkData.link);
    }).onError(handleError);
  }

  static void handleError(Object? _) {
    NavigationService.navigateTo('/error');
  }

  static void redirect(String route, arguments) {
    if (!initialLinkGathered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationService.navigateToWithArguments(route, arguments);
      });
    } else {
      NavigationService.navigateToWithArguments(route, arguments);
    }
  }

  static Future<void> startUrl() async {
    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink == null) {
      return;
    }

    handleRouteRedirection(initialLink.link);
    initialLinkGathered = true;
  }

  static void handleRouteRedirection(Uri uri) async {
    switch (uri.pathSegments.first) {
      case 'sight':
        String? id = uri.queryParameters['id'];

        if (id == null) {
          handleError(null);
          return;
        }

        Sight? sight = await SightController().findSight(id);

        if (sight == null) {
          handleError(null);
          return;
        }

        redirect('/sight', sight);
        break;
      case 'tour':
        String? id = uri.queryParameters['id'];

        if (id == null) {
          handleError(null);
          return;
        }

        Tour? tour = await TourController().findTour(id);

        if (tour == null) {
          handleError(null);
          return;
        }

        redirect('/tour', tour);
        break;
      default:
        handleError(null);
    }
  }
}

/*
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
*/