import 'dart:convert';
import 'dart:io';
import 'package:visit_braila/models/personality_model.dart';
import 'package:http/http.dart' as http;
import 'package:visit_braila/utils/url_constants.dart';

class PersonalityController {
  Future<List<Personality>> fetchPersonalities(String type) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchPersonalities?type=$type"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((personalityJSON) => Personality.fromJSON(personalityJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<Personality?> findPersonality(String id) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/findPersonality/$id"));

      if (response.statusCode == 200) {
        return Personality.fromJSON(jsonDecode(response.body));
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      return null;
    }
  }
}
