import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isIOS
          ? const CupertinoActivityIndicator(
              radius: 15,
            )
          : CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Theme.of(context).primaryColor,
            ),
    );
  }
}
