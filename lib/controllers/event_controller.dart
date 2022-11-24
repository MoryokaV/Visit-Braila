import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/utils/url_constants.dart';

class EventController {
  Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/fetchEvents"));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        return data.map((eventJSON) => Event.fromJSON(eventJSON)).toList();
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      rethrow;
    }
  }

  Future<Event?> findEvent(String id) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/findEvent/$id"));

      if (response.statusCode == 200) {
        return Event.fromJSON(jsonDecode(response.body));
      } else {
        throw HttpException("INTERNAL SERVER ERROR: ${response.statusCode}");
      }
    } on HttpException {
      return null;
    }
  }
}
