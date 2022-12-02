import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:visit_braila/utils/url_constants.dart';

class AboutController {
  Future<String> fetchAboutParagraph1() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchAboutParagraph1"));

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);

        return data['content'] as String;
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<String> fetchAboutParagraph2() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchAboutParagraph2"));

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);

        return data['content'] as String;
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchContactDetails() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchContactDetails"));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        return data;
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }
}
