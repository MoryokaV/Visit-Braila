import 'package:flutter/material.dart';
import 'package:visit_braila/views/sight_view.dart';
import 'package:visit_braila/widgets/bottom_navbar.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => const BottomNavbar());
      case '/sight':
        final id = settings.arguments as String;
        return MaterialPageRoute(builder: (context) => SightView(id: id));
      default:
        return MaterialPageRoute(builder: (context) => const BottomNavbar());
    }
  }
}
