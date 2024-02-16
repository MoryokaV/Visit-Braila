class Question {
  final String text;
  final int correctAnswear;
  final List<String>? answears;

  Question({
    required this.text,
    required this.correctAnswear,
    this.answears,
  });
}
