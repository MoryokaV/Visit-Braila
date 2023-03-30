import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:visit_braila/services/localstorage_service.dart';

class Wishlist extends ChangeNotifier {
  Map<String, Set<String>> items = {
    "sights": {},
    "tours": {},
    "hotels": {},
  };

  Wishlist() {
    loadWishlist();
  }

  void loadWishlist() {
    String? localWishlist = LocalStorage.getWishlist();

    if (localWishlist == null) {
      return;
    }

    items = convertToSet(jsonDecode(localWishlist));
  }

  void toggleSightWishState(String id) {
    items['sights']!.contains(id) ? items['sights']!.remove(id) : items['sights']!.add(id);

    LocalStorage.saveWishlist(jsonEncode(convertToList()));

    notifyListeners();
  }

  void toggleTourWishState(String id) {
    items['tours']!.contains(id) ? items['tours']!.remove(id) : items['tours']!.add(id);

    LocalStorage.saveWishlist(jsonEncode(convertToList()));

    notifyListeners();
  }

  Map<String, List<String>> convertToList() {
    return {
      "sights": List<String>.from(items['sights']!),
      "tours": List<String>.from(items['tours']!),
    };
  }

  Map<String, Set<String>> convertToSet(Map<String, dynamic> json) {
    return {
      "sights": Set<String>.from(json['sights']),
      "tours": Set<String>.from(json['tours']),
    };
  }
}
