import 'package:visit_braila/utils/url_constants.dart';

class Personality {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int primaryImage;
  final String primaryImageBlurhash;
  final String? sightLink;
  final String pdf;

  Personality({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.primaryImage,
    required this.primaryImageBlurhash,
    required this.sightLink,
    required this.pdf,
  });

  factory Personality.fromJSON(Map<String, dynamic> json) {
    return Personality(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      images: List<String>.from(json['images'].map((image) => "$baseUrl$image")),
      primaryImage: json['primary_image'],
      primaryImageBlurhash: json['primary_image_blurhash'],
      sightLink: json['sight_link'],
      pdf: "$baseUrl${json['pdf']}",
    );
  }
}
