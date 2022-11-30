import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/controllers/event_controller.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/utils/navigation_util.dart';
import 'package:visit_braila/widgets/bottom_navbar.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class MessagingService {
  static init() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationData(initialMessage);
      });
    }

    await FirebaseMessaging.instance.subscribeToTopic("events");

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationData(message);
    });
  }

  static void handleError() {
    NavigationUtil.navigateTo('/error');
  }

  static void redirect(String route, arguments) {
    NavigationUtil.navigateToWithArguments(route, arguments);
  }

  static void handleNotificationData(RemoteMessage message) async {
    switch (message.data['type']) {
      case 'event':
        String? id = message.data['id'];

        if (id == null) {
          handleError();
          return;
        }

        Event? event = await EventController().findEvent(id);

        if (event == null) {
          handleError();
          return;
        }

        redirect('/event', event);
        break;
      case 'tomorrow_events':
        Navigator.popUntil(NavigationUtil.navigatorKey.currentContext!, (route) => route.isFirst);

        break;
      default:
        return;
    }
  }

  static Future<bool> checkNotificationPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      return true;
    } else {
      return false;
    }
  }
}
