import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/services/messaging_service.dart';
import 'package:visit_braila/utils/style.dart';

class NotificationsButton extends StatefulWidget {
  const NotificationsButton({super.key});

  @override
  State<NotificationsButton> createState() => _NotificationsButtonState();
}

class _NotificationsButtonState extends State<NotificationsButton> with WidgetsBindingObserver {
  bool isLoading = true;
  late bool notificationsEnabled;

  @override
  void initState() {
    super.initState();

    getPermissionStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  void getPermissionStatus() async {
    notificationsEnabled = await MessagingService.checkNotificationPermission();

    setState(() => isLoading = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => isLoading = true);

      getPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox()
        : IconButton(
            onPressed: () {
              AppSettings.openNotificationSettings();
            },
            icon: Icon(
              notificationsEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
              color: kForegroundColor,
            ),
          );
  }
}
