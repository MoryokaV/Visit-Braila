import 'package:visit_braila/models/stage_model.dart';
import 'package:visit_braila/utils/url_constants.dart';

class Tour {
  final String id;
  final String name;
  final List<Stage> stages;
  final String description;
  final List<String> images;
  final int primaryImage;
  final double length;
  final String externalLink;

  const Tour({
    required this.id,
    required this.name,
    required this.stages,
    required this.description,
    required this.images,
    required this.primaryImage,
    required this.length,
    required this.externalLink,
  });

  factory Tour.fromJSON(Map<String, dynamic> json) {
    return Tour(
      id: json['_id'],
      name: json['name'],
      stages: List<Stage>.from(json['stages'].map((stage) => Stage.fromJSON(stage))),
      description: json['description'],
      images: List<String>.from(json['images'].map((image) => "$baseUrl$image")),
      primaryImage: json['primary_image'],
      length: json['length'].toDouble(),
      externalLink: json['external_link'],
    );
  }
}
