class Question {
  final String text;
  final Answear answearType;
  final int correctAnswear;
  final List<String>? answears;

  Question({
    required this.text,
    required this.answearType,
    required this.correctAnswear,
    this.answears,
  });
}

enum Answear {
  multipleChoice,
  trueFalse,
}
