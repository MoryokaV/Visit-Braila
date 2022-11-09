import 'dart:convert';
import 'dart:io';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/utils/url_constants.dart';
import 'package:http/http.dart' as http;

class TourController {
  Future<List<Tour>> fetchTours() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchTours"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((tourJSON) => Tour.fromJSON(tourJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<Tour> findTour(String id) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/findTour/$id"));

      if (response.statusCode == 200) {
        return Tour.fromJSON(jsonDecode(response.body));
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }
}
