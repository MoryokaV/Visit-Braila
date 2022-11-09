import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

void showErrorDialog(BuildContext context, bool isServerError) {
  const String title = "Eroare";
  const String content = "Auch! Serverul a întâmpinat o problemă. Reîncearcă mai târziu.";

  Future.delayed(Duration.zero, () {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text(title),
          content: const Text(content),
          actions: [
            CupertinoDialogAction(
              child: const Text("Ok"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(title),
          content: const Text(content),
          actions: [
            TextButton(
              child: const Text("Ok"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  });
}
