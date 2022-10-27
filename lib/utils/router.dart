import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/views/gallery_view.dart';
import 'package:visit_braila/views/notfound_view.dart';
import 'package:visit_braila/views/sight_view.dart';
import 'package:visit_braila/widgets/bottom_navbar.dart';
import 'dart:io' show Platform;

class PageRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return adaptivePageRoute(builder: (context) => const BottomNavbar());
      case '/sight':
        final sight = settings.arguments as Sight;

        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, _) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(0, 0.5),
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: SightView(
                sight: sight,
                routeAnimation: animation,
              ),
            );
          },
        );
      case '/gallery':
        final args = settings.arguments as Map<String, dynamic>;

        return adaptivePageRoute(
          builder: (context) => GalleryView(
            startIndex: args['startIndex'],
            images: args['images'],
            title: args['title'],
            id: args['id'],
          ),
        );
      default:
        return null;
    }
  }

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const NotFoundView());
  }

  static Route<dynamic> adaptivePageRoute({required Widget Function(BuildContext) builder}) {
    return Platform.isIOS ? CupertinoPageRoute(builder: builder) : MaterialPageRoute(builder: builder);
  }
}
