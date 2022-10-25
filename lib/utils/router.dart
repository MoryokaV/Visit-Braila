import 'package:flutter/material.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/views/notfound_view.dart';
import 'package:visit_braila/views/sight_view.dart';
import 'package:visit_braila/widgets/bottom_navbar.dart';

class PageRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => const BottomNavbar());
      case '/sight':
        final sight = settings.arguments as Sight;

        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) {
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
      default:
        return null;
    }
  }

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const NotFoundView());
  }
}
