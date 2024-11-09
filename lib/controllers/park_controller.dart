import 'dart:convert';
import 'dart:io';
import 'package:visit_braila/models/park_model.dart';
import 'package:http/http.dart' as http;
import 'package:visit_braila/utils/url_constants.dart';

class ParkController {
  Future<List<Park>> fetchParks() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchParks"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((parkJSON) => Park.fromJSON(parkJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }
}
