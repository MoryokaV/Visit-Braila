import 'dart:ui';
import 'package:visit_braila/models/question_model.dart';

class Quiz {
  final String id;
  final String title;
  final String icon;
  final Color color;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

List<Quiz> quizes = [
  Quiz(
    id: "quiz1",
    title: "Istorie",
    icon: "assets/icons/history.svg",
    color: const Color(0xffff6b6b),
    questions: [
      Question(
        text: "În ce an a luat ființă Expoziția memorială permanenta 'Panait Istrati'?",
        answearType: Answear.multipleChoice,
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
    color: const Color(0xffffa94d),
    questions: [
      Question(
        text: "Care a fost una dintre meseriile lui D.P.Perpessicius?",
        answearType: Answear.multipleChoice,
        correctAnswear: 2,
        answears: [
          "Agricultor",
          "Critic literar",
          "Arhitect",
        ],
      ),
    ],
  ),
  Quiz(
    id: "quiz3",
    title: "Geografie",
    icon: "assets/icons/geography.svg",
    color: const Color(0xff12b886),
    questions: [
      Question(
        text: "Unde se afla Muzeul de istorie Carol I?",
        answearType: Answear.multipleChoice,
        correctAnswear: 4,
        answears: [
          "Bulevardul Dorobantilor",
          "Piata Poligon",
          "Calea Calarasilor",
          "Piata Traian",
        ],
      ),
      Question(
        text: "Braila nu are iesire la Dunare",
        answearType: Answear.trueFalse,
        correctAnswear: 0,
      ),
    ],
  ),
  Quiz(
    id: "quiz4",
    title: "Religie",
    icon: "assets/icons/cross.svg",
    color: const Color(0xffadb5bd),
    questions: [
      Question(
        text: "Biserica Greacă are hramul 'buna vestire'?",
        answearType: Answear.trueFalse,
        correctAnswear: 1,
      ),
    ],
  ),
];
