import 'package:visit_braila/utils/url_constants.dart';

class Park {
  final String id;
  final String name;
  final List<String> images;
  final int primaryImage;
  final String primaryImageBlurhash;
  final double latitude;
  final double longitude;
  final ParkType type;

  const Park({
    required this.id,
    required this.name,
    required this.images,
    required this.primaryImage,
    required this.primaryImageBlurhash,
    required this.latitude,
    required this.longitude,
    required this.type,
  });

  factory Park.fromJSON(Map<String, dynamic> json) {
    return Park(
      id: json['_id'],
      name: json['name'],
      images: List<String>.from(json['images'].map((image) => "$baseUrl$image")),
      primaryImage: json['primary_image'],
      primaryImageBlurhash: json['primary_image_blurhash'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      type: ParkType.values.byName(json['type']),
    );
  }
}

enum ParkType {
  relaxare,
  joaca,
  fitness,
}
