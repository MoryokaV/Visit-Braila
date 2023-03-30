import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:visit_braila/models/hotel_model.dart';
import 'package:visit_braila/utils/url_constants.dart';

class HotelController {
  Future<List<Hotel>> fetchHotels() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchHotels"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((hotelJSON) => Hotel.fromJSON(hotelJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<Hotel?> findHotel(String id) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/findHotel/$id"));

      if (response.statusCode == 200) {
        return Hotel.fromJSON(jsonDecode(response.body));
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      return null;
    }
  }

  Future<List<String>> fetchHotelsTags() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchTags/hotels"));

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