import 'package:visit_braila/utils/url_constants.dart';

class Event {
  final String id;
  final String name;
  final DateTime dateTime;
  final String description;
  final List<String> images;
  final int primaryImage;

  Event({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.description,
    required this.images,
    required this.primaryImage,
  });

  factory Event.fromJSON(Map<String, dynamic> json){
    return Event(
      id: json['_id'],
      name: json['name'],
      dateTime: json['date_time'],
      description: json['description'],
      images: List<String>.from(json['images'].map((image) => "$baseUrl$image")),
      primaryImage: json['primary_image'],
    );
  }
}
