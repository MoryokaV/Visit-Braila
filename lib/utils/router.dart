import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/models/fitness_model.dart';
import 'package:visit_braila/models/hotel_model.dart';
import 'package:visit_braila/models/madeinbraila_model.dart';
import 'package:visit_braila/models/restaurant_model.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/services/connection_service.dart';
import 'package:visit_braila/views/all_fitness_view.dart';
import 'package:visit_braila/views/all_hotels_view.dart';
import 'package:visit_braila/views/all_madeinbraila_view.dart';
import 'package:visit_braila/views/all_parks_view.dart';
import 'package:visit_braila/views/all_personalities_view.dart';
import 'package:visit_braila/views/all_restaurants_view.dart';
import 'package:visit_braila/views/all_sights_view.dart';
import 'package:visit_braila/views/all_tours_view.dart';
import 'package:visit_braila/views/event_view.dart';
import 'package:visit_braila/views/fitness_view.dart';
import 'package:visit_braila/views/gallery_view.dart';
import 'package:visit_braila/views/hotel_view.dart';
import 'package:visit_braila/views/madeinbraila_view.dart';
import 'package:visit_braila/views/nointernet_view.dart';
import 'package:visit_braila/views/notfound_view.dart';
import 'package:visit_braila/views/personality_view.dart';
import 'package:visit_braila/views/restaurant_view.dart';
import 'package:visit_braila/views/sight_view.dart';
import 'package:visit_braila/views/tour_view.dart';
import 'package:visit_braila/widgets/bottom_navbar.dart';
import 'dart:io' show Platform;

const kTransitionDuration = Duration(milliseconds: 500);
const kTransitionCurve = Interval(0, 0.5);

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

        return createFadeInRouteTransition((animation) => SightView(sight: sight, routeAnimation: animation));
      case '/tour':
        final tour = settings.arguments as Tour;

        return createFadeInRouteTransition((animation) => TourView(tour: tour, routeAnimation: animation));
      case '/hotel':
        final hotel = settings.arguments as Hotel;

        return createFadeInRouteTransition((animation) => HotelView(hotel: hotel, routeAnimation: animation));
      case '/personality':
        final args = settings.arguments as Map<String, dynamic>;

        return createFadeInRouteTransition(
          (animation) => PersonalityView(
            personality: args['personality'],
            sightName: args['sightName'],
            routeAnimation: animation,
          ),
        );
      case '/restaurant':
        final restaurant = settings.arguments as Restaurant;

        return createFadeInRouteTransition(
            (animation) => RestaurantView(restaurant: restaurant, routeAnimation: animation));
      case '/event':
        final event = settings.arguments as Event;

        return createFadeInRouteTransition((animation) => EventView(event: event, routeAnimation: animation));
      case '/fitness':
        final fitness = settings.arguments as Fitness;

        return createFadeInRouteTransition((animation) => FitnessView(fitness: fitness, routeAnimation: animation));
      case '/madeinbraila':
        final madeInBraila = settings.arguments as MadeInBraila;

        return createFadeInRouteTransition(
            (animation) => MadeInBrailaView(madeInBraila: madeInBraila, routeAnimation: animation));
      case '/alltours':
        return adaptivePageRoute(builder: (context) => const AllToursView());
      case '/allsights':
        return adaptivePageRoute(builder: (context) => const AllSightsView());
      case '/allpersonalities':
        return adaptivePageRoute(builder: (context) => const AllPersonalitiesView());
      case '/allhotels':
        return adaptivePageRoute(builder: (context) => const AllHotelsView());
      case '/allrestaurants':
        return adaptivePageRoute(builder: (context) => const AllRestaurantsView());
      case '/allfitness':
        return adaptivePageRoute(builder: (context) => const AllFitnessView());
      case '/allparks':
        return adaptivePageRoute(builder: (context) => const AllParksView());
      case '/allmadeinbraila':
        return adaptivePageRoute(builder: (context) => const AllMadeInBrailaView());
      case '/gallery':
        final args = settings.arguments as Map<String, dynamic>;

        return adaptivePageRoute(
          builder: (context) => GalleryView(
            startIndex: args['startIndex'],
            images: args['images'],
            title: args['title'],
            id: args['id'],
            collection: args['collection'],
            type: args['type'],
            primaryImage: args['primaryImage'],
            externalLink: args['externalLink'],
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

  static PageRouteBuilder createFadeInRouteTransition(Widget Function(Animation<double> animation) builder) {
    return PageRouteBuilder(
      transitionDuration: kTransitionDuration,
      reverseTransitionDuration: kTransitionDuration,
      pageBuilder: (context, animation, _) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: kTransitionCurve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: builder(animation),
        );
      },
    );
  }

  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const NotFoundView());
  }

  static Route<dynamic> adaptivePageRoute({required Widget Function(BuildContext) builder}) {
    return Platform.isIOS ? CupertinoPageRoute(builder: builder) : MaterialPageRoute(builder: builder);
  }
}
