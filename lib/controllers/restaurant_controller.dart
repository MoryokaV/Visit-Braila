import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:visit_braila/models/restaurant_model.dart';
import 'package:visit_braila/utils/url_constants.dart';

class RestaurantController {
  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchRestaurants"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((restaurantJSON) => Restaurant.fromJSON(restaurantJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<Restaurant?> findRestaurant(String id) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/findRestaurant/$id"));

      if (response.statusCode == 200) {
        return Restaurant.fromJSON(jsonDecode(response.body));
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      return null;
    }
  }

  Future<List<String>> fetchRestaurantsTags() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchTags/restaurants"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((tagJSON) => tagJSON['name'] as String).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }
}
