import 'package:visit_braila/utils/url_constants.dart';

class Hotel {
  final String name;
  final int stars;
  final String phone;
  final List<String> tags;
  final String description;
  final List<String> images;
  final int primaryImage;
  final double latitude;
  final double longitude;
  final String externalLink;

  Hotel({
    required this.name,
    required this.stars,
    required this.phone,
    required this.tags,
    required this.description,
    required this.images,
    required this.primaryImage,
    required this.latitude,
    required this.longitude,
    required this.externalLink,
  });

  factory Hotel.fromJSON(Map<String, dynamic> json) {
    return Hotel(
      name: json['name'],
      stars: json['stars'],
      phone: json['phone'],
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
