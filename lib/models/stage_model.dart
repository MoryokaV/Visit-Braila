class Stage {
  final String text;
  final String sightLink;

  Stage({
    required this.text,
    required this.sightLink,
  });

  factory Stage.fromJSON(Map<String, dynamic> json) {
    return Stage(
      text: json['text'],
      sightLink: json['sight_link'],
    );
  }
}
