import 'dart:convert';
import 'dart:io';
import 'package:visit_braila/models/sight_model.dart';
import 'package:http/http.dart' as http;
import 'package:visit_braila/utils/url_constants.dart';

class SightController {
  Future<List<Sight>> fetchSights() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchSights"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((sightJSON) => Sight.fromJSON(sightJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<Sight> findSight(String id) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/findSight/$id"));

      if (response.statusCode == 200) {
        return Sight.fromJSON(jsonDecode(response.body));
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<List<Sight>> fetchTrending() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchTrendingItems"));

      if (response.statusCode == 200) {
        List trending = jsonDecode(response.body);

        return await Future.wait(
          trending.map((item) => findSight(item['sight_id'])),
        );
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<List<String>> fetchAllTags() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchTags"));

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
