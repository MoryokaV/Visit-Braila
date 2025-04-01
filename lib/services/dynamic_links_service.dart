// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/controllers/event_controller.dart';
import 'package:visit_braila/controllers/fitness_controller.dart';
import 'package:visit_braila/controllers/hotel_controller.dart';
import 'package:visit_braila/controllers/madeinbraila_controller.dart';
import 'package:visit_braila/controllers/restaurant_controller.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/models/fitness_model.dart';
import 'package:visit_braila/models/hotel_model.dart';
import 'package:visit_braila/models/madeinbraila_model.dart';
import 'package:visit_braila/models/restaurant_model.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/utils/navigation_util.dart';

const String uriPrefix = "https://visitbraila.page.link";
final FirebaseDynamicLinks _firebaseDynamicLinks = FirebaseDynamicLinks.instance;

class DynamicLinksService {
  static bool handleInitialLink = true;

  static Future<Uri> generateDynamicLink({
    required String id,
    required String image,
    required String name,
    required String collection,
    required String alternativeUrl,
  }) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("$uriPrefix/$collection?id=$id"),
      uriPrefix: uriPrefix,
      androidParameters: AndroidParameters(
        fallbackUrl: Uri.parse(alternativeUrl),
        packageName: "com.vmasoftware.visit_braila",
      ),
      iosParameters: IOSParameters(
        appStoreId: "6448944001",
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

    final dynamicLink = await _firebaseDynamicLinks.buildShortLink(
      dynamicLinkParams,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    return dynamicLink.shortUrl;
  }

  static init() async {
    _firebaseDynamicLinks.onLink.listen((dynamicLinkData) {
      handleRouteRedirection(dynamicLinkData.link);
    }).onError(handleError);
  }

  static void handleError(Object? _) {
    NavigationUtil.navigateTo('/error');
  }

  static void redirect(String route, arguments) {
    if (handleInitialLink) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationUtil.navigateToWithArguments(route, arguments);
      });

      handleInitialLink = false;
    } else {
      NavigationUtil.navigateToWithArguments(route, arguments);
    }
  }

  static Future<void> startUrl() async {
    if (Platform.isIOS) {
      return;
    }

    final PendingDynamicLinkData? initialLink = await _firebaseDynamicLinks.getInitialLink();

    if (initialLink == null) {
      handleInitialLink = false;
      return;
    }

    handleRouteRedirection(initialLink.link);
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
      case 'hotel':
        String? id = uri.queryParameters['id'];

        if (id == null) {
          handleError(null);
          return;
        }

        Hotel? hotel = await HotelController().findHotel(id);

        if (hotel == null) {
          handleError(null);
          return;
        }

        redirect('/hotel', hotel);
        break;
      case 'restaurant':
        String? id = uri.queryParameters['id'];

        if (id == null) {
          handleError(null);
          return;
        }

        Restaurant? restaurant = await RestaurantController().findRestaurant(id);

        if (restaurant == null) {
          handleError(null);
          return;
        }

        redirect('/restaurant', restaurant);
        break;
      case 'event':
        String? id = uri.queryParameters['id'];

        if (id == null) {
          handleError(null);
          return;
        }

        Event? event = await EventController().findEvent(id);

        if (event == null) {
          handleError(null);
          return;
        }

        redirect('/event', event);
        break;
      case 'fitness':
        String? id = uri.queryParameters['id'];

        if (id == null) {
          handleError(null);
          return;
        }

        Fitness? fitness = await FitnessController().findFitness(id);

        if (fitness == null) {
          handleError(null);
          return;
        }

        redirect('/fitness', fitness);
        break;
      case 'madeinbraila':
        String? id = uri.queryParameters['id'];

        if (id == null) {
          handleError(null);
          return;
        }

        MadeInBraila? madeInBraila = await MadeInBrailaController().findMadeInBraila(id);

        if (madeInBraila == null) {
          handleError(null);
          return;
        }

        redirect('/madeinbraila', madeInBraila);
        break;
      default:
        handleError(null);
    }
  }
}
