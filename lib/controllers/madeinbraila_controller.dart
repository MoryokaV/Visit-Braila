import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:visit_braila/models/madeinbraila_model.dart';
import 'package:visit_braila/utils/url_constants.dart';

class MadeInBrailaController {
  Future<List<MadeInBraila>> fetchMadeInBraila() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchMadeInBraila"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((madeInBrailaJSON) => MadeInBraila.fromJSON(madeInBrailaJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<MadeInBraila?> findMadeInBraila(String id) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/findMadeInBraila/$id"));

      if (response.statusCode == 200) {
        return MadeInBraila.fromJSON(jsonDecode(response.body));
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      return null;
    }
  }

  Future<List<String>> fetchMadeInBrailaTags() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchTags/madeinbraila"));

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
