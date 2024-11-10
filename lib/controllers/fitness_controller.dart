import 'dart:convert';
import 'dart:io';
import 'package:visit_braila/models/fitness_model.dart';
import 'package:http/http.dart' as http;
import 'package:visit_braila/utils/url_constants.dart';

class FitnessController {
  Future<List<Fitness>> fetchFitness() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchFitness"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((fitnessJSON) => Fitness.fromJSON(fitnessJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<Fitness?> findFitness(String id) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/findFitness/$id"));

      if (response.statusCode == 200) {
        return Fitness.fromJSON(jsonDecode(response.body));
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      return null;
    }
  }
}
