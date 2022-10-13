import 'dart:convert';
import 'package:visit_braila/models/sight_model.dart';
import 'package:http/http.dart' as http;
import 'package:visit_braila/utils/url_constants.dart';

class SightController {
  Future<Sight> findSight(String id) async {
    final response = await http.get(Uri.parse("$apiUrl/findSight/$id"));

    if (response.statusCode == 200) {
      return Sight.fromJSON(jsonDecode(response.body));
    } else {
      throw Exception("Error: Find sight - $response.statusCode");
    }
  }

  Future<List<Sight>> fetchTrending() async {
    final response =
        await http.get(Uri.parse("$apiUrl/fetchTrendingItems"));

    if (response.statusCode == 200) {
      List trending = jsonDecode(response.body);

      return await Future.wait(trending.map((item) => findSight(item['sight_id'])));
    } else {
      throw Exception("Error: Fetch trending - $response.statusCode");
    }
  }
}
