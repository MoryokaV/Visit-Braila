import 'dart:ui';
import 'package:visit_braila/models/question_model.dart';

class Quiz {
  final String id;
  final String title;
  final String icon;
  final Color iconBgColor;
  final Answear answearType;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.answearType,
    required this.questions,
  });
}

List<Quiz> quizes = [
  Quiz(
    id: "quiz1",
    title: "Istorie",
    icon: "assets/icons/history.svg",
    iconBgColor: const Color(0xffff8787),
    answearType: Answear.multipleChoice,
    questions: [
      Question(
        text: "În ce an a luat ființă Expoziția memorială permanenta 'Panait Istrati'",
        correctAnswear: 1,
        answears: [
          "1984",
          "1999",
          "2001",
          "1960",
        ],
      ),
    ],
  ),
  Quiz(
    id: "quiz2",
    title: "Personalități",
    icon: "assets/icons/people.svg",
    iconBgColor: const Color(0xffa9e34b),
    answearType: Answear.multipleChoice,
    questions: [],
  ),
  Quiz(
    id: "quiz3",
    title: "Geografie",
    icon: "assets/icons/geography.svg",
    iconBgColor: const Color(0xffffc078),
    answearType: Answear.multipleChoice,
    questions: [],
  ),
  Quiz(
    id: "quiz4",
    title: "Religie",
    icon: "assets/icons/cross.svg",
    iconBgColor: const Color(0xffced4da),
    answearType: Answear.multipleChoice,
    questions: [],
  ),
];

enum Answear {
  multipleChoice,
  trueFalse,
}
