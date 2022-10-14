import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Wishlist extends ChangeNotifier {
  Map<String, Set<String>> items = {
    "sights": {},
    "tours": {},
  };

  void toggleSightWishState(String id) {
    items['sights']!.contains(id)
        ? items['sights']!.remove(id)
        : items['sights']!.add(id);

    notifyListeners();
  }

  void toggleTourWishState(String id) {
    items['tours']!.contains(id)
        ? items['tours']!.remove(id)
        : items['tours']!.add(id);

    notifyListeners();
  }
}
