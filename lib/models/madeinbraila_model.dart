import 'package:visit_braila/utils/url_constants.dart';

class MadeInBraila {
  final String id;
  final String name;
  final String phone;
  final List<String> tags;
  final String description;
  final List<String> images;
  final int primaryImage;
  final String primaryImageBlurhash;
  final double latitude;
  final double longitude;
  final String externalLink;

  MadeInBraila({
    required this.id,
    required this.name,
    required this.phone,
    required this.tags,
    required this.description,
    required this.images,
    required this.primaryImage,
    required this.primaryImageBlurhash,
    required this.latitude,
    required this.longitude,
    required this.externalLink,
  });

  factory MadeInBraila.fromJSON(Map<String, dynamic> json) {
    return MadeInBraila(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      tags: List<String>.from(json['tags'].map((tag) => tag)),
      description: json['description'],
      images: List<String>.from(json['images'].map((image) => "$baseUrl$image")),
      primaryImage: json['primary_image'],
      primaryImageBlurhash: json['primary_image_blurhash'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      externalLink: json['external_link'],
    );
  }
}
