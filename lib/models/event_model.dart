import 'package:visit_braila/utils/url_constants.dart';

class Event {
  final String id;
  final String name;
  final DateTime dateTime;
  final DateTime? endDateTime;
  final String description;
  final List<String> images;
  final int primaryImage;
  final String primaryImageBlurhash;
  final String externalLink = obiectivUrl;

  Event({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.endDateTime,
    required this.description,
    required this.images,
    required this.primaryImage,
    required this.primaryImageBlurhash,
  });

  factory Event.fromJSON(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      name: json['name'],
      dateTime: DateTime.parse(json['date_time']).add(DateTime.parse(json['date_time']).timeZoneOffset),
      endDateTime: json['end_date_time'] == null
          ? null
          : DateTime.parse(json['end_date_time']).add(DateTime.parse(json['end_date_time']).timeZoneOffset),
      description: json['description'],
      images: List<String>.from(json['images'].map((image) => "$baseUrl$image")),
      primaryImage: json['primary_image'],
      primaryImageBlurhash: json['primary_image_blurhash'],
    );
  }
}
