import 'package:visit_braila/utils/url_constants.dart';

class Sight {
  final String id;
  final String name;
  final List<String> tags;
  final String description;
  final List<String> images;
  final int primaryImage;
  final double latitude;
  final double longitude;
  final String externalLink;

  const Sight({
    required this.id,
    required this.name,
    required this.tags,
    required this.description,
    required this.images,
    required this.primaryImage,
    required this.latitude,
    required this.longitude,
    required this.externalLink,
  });

  factory Sight.fromJSON(Map<String, dynamic> json) {
    return Sight(
      id: json['_id'],
      name: json['name'],
      tags: List<String>.from(json['tags'].map((tag) => tag)),
      description: json['description'],
      images: List<String>.from(json['images'].map((image) => "$baseUrl$image")),
      primaryImage: json['primary_image'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      externalLink: json['external_link'],
    );
  }
}
