import 'package:visit_braila/utils/url_constants.dart';

class Fitness {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int primaryImage;
  final double latitude;
  final double longitude;
  final String externalLink;

  const Fitness({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.primaryImage,
    required this.latitude,
    required this.longitude,
    required this.externalLink,
  });

  factory Fitness.fromJSON(Map<String, dynamic> json) {
    return Fitness(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      images: List<String>.from(json['images'].map((image) => "$baseUrl$image")),
      primaryImage: json['primary_image'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      externalLink: json['external_link'],
    );
  }
}
