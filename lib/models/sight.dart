class Sight {
  final String name;
  final List<String> tags;
  final String description;
  final List<String> images;
  final String position;
  final int primaryImage;

  const Sight({
    required this.name,
    required this.tags,
    required this.description,
    required this.images,
    required this.position,
    required this.primaryImage,
  });

  factory Sight.fromJSON(Map<String, dynamic> json) {
    return Sight(
      name: json['name'],
      tags: json['tags'],
      description: json['description'],
      images: json['images'],
      position: json['position'],
      primaryImage: json['primary_image'],
    );
  }
}