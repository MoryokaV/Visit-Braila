import 'dart:convert';
import 'dart:io';
import 'package:visit_braila/controllers/hotel_controller.dart';
import 'package:visit_braila/controllers/restaurant_controller.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:http/http.dart' as http;
import 'package:visit_braila/utils/url_constants.dart';

class TrendingController {
  final SightController sightController = SightController();
  final RestaurantController restaurantController = RestaurantController();
  final HotelController hotelController = HotelController();

  Future<List<Object?>> fetchTrending() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchTrendingItems"));

      if (response.statusCode == 200) {
        List trending = jsonDecode(response.body);

        List<Object?> data = await Future.wait(
          trending.map((item) {
            switch (item['type']) {
              case "sight":
                return sightController.findSight(item['item_id']);
              case "restaurant":
                return restaurantController.findRestaurant(item['item_id']);
              case "hotel":
                return hotelController.findHotel(item['item_id']);
              default:
                return Future.value(null);
            }
          }),
        );

        return data;
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }
}
