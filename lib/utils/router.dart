import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/services/connection_service.dart';
import 'package:visit_braila/views/all_hotels_view.dart';
import 'package:visit_braila/views/all_sights_view.dart';
import 'package:visit_braila/views/all_tours_view.dart';
import 'package:visit_braila/views/event_view.dart';
import 'package:visit_braila/views/gallery_view.dart';
import 'package:visit_braila/views/nointernet_view.dart';
import 'package:visit_braila/views/notfound_view.dart';
import 'package:visit_braila/views/sight_view.dart';
import 'package:visit_braila/views/tour_view.dart';
import 'package:visit_braila/widgets/bottom_navbar.dart';
import 'dart:io' show Platform;

class PageRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return PageRouteBuilder(
          pageBuilder: (context, _, __) {
            if (!Platform.isIOS) {
              final connection = Provider.of<ConnectionService>(context, listen: false);
              if (!connection.isOnline) {
                return const NoInternetView();
              }
            }

            return const BottomNavbar();
          },
        );
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
      case '/tour':
        final tour = settings.arguments as Tour;

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
              child: TourView(
                tour: tour,
                routeAnimation: animation,
              ),
            );
          },
        );
      case '/event':
        final event = settings.arguments as Event;

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
              child: EventView(
                event: event,
                routeAnimation: animation,
              ),
            );
          },
        );
      case '/alltours':
        return adaptivePageRoute(builder: (context) => const AllToursView());
      case '/allsights':
        return adaptivePageRoute(builder: (context) => const AllSightsView());
      case '/allhotels':
        return adaptivePageRoute(builder: (context) => const AllHotelsView());
      case '/gallery':
        final args = settings.arguments as Map<String, dynamic>;

        return adaptivePageRoute(
          builder: (context) => GalleryView(
            startIndex: args['startIndex'],
            sight: args['sight'],
            tour: args['tour'],
            event: args['event'],
          ),
        );
      case '/nointernet':
        return PageRouteBuilder(
          pageBuilder: (context, _, __) {
            return const NoInternetView();
          },
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
