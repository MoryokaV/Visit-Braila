import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:visit_braila/controllers/event_controller.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/utils/navigation_util.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class MessagingServce {
  static init() async {
    // print(await FirebaseMessaging.instance.getToken());

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationData(initialMessage);
      });
    }

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
    if (message.data['type'] != "event") {
      return;
    }

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
  }
}
