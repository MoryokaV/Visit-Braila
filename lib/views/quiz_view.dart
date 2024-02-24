import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/models/question_model.dart';
import 'package:visit_braila/models/quiz_model.dart';
import 'package:visit_braila/providers/quiz_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';

class QuizView extends StatefulWidget {
  final Quiz? quiz;

  const QuizView({
    this.quiz,
    super.key,
  });

  @override
  State<QuizView> createState() => QuizViewState();
}

class QuizViewState extends State<QuizView> {
  int questionIndex = 0;
  int? selectedAnswear;
  bool failed = false;
  bool completed = false;

  late Quiz quiz;

  final List<String> letters = ["A", "B", "C", "D"];

  @override
  void initState() {
    if (widget.quiz == null) {
      List<Question> questions = [];

      for (Quiz q in quizes) {
        q.questions.forEach(questions.add);
      }

      questions.shuffle();

      quiz = Quiz(
        id: "quiz0",
        title: "Cultură generală",
        icon: "assets/icons/mortarboard.svg",
        color: const Color(0xff4dabf7),
        questions: questions,
      );
    } else {
      quiz = widget.quiz!;
      quiz.questions.shuffle();
    }

    super.initState();
  }

  Widget mainContent(BuildContext context) {
    if (failed) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          children: [
            const SizedBox(height: 28),
            SvgPicture.asset(
              "assets/illustrations/fail.svg",
              width: Responsive.screenWidth / 1.75,
            ),
            const SizedBox(height: 14),
            const Text(
              "Ai greșit!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Întoarce-te la ecranul principal și continuă să răsfoiești și să studiezi obiectivele turistice. Mai încearcă!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: questionIndex / quiz.questions.length,
                          color: quiz.color,
                          backgroundColor: quiz.color.withAlpha(50),
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Center(
                        child: Text(
                          "$questionIndex/${quiz.questions.length}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Inter",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: Text(
                    "Ai răspuns la $questionIndex din ${quiz.questions.length} întrebări",
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      );
    }

    if (completed) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          children: [
            const SizedBox(height: 28),
            SvgPicture.asset(
              "assets/illustrations/completed.svg",
              width: Responsive.screenWidth / 2.25,
            ),
            const SizedBox(height: 14),
            const Text(
              "Felicitări!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Ai terminat întreg modulul de ${quiz.title.toLowerCase()}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: questionIndex / quiz.questions.length,
                          color: quiz.color,
                          backgroundColor: quiz.color.withAlpha(50),
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Center(
                        child: Text(
                          "$questionIndex/${quiz.questions.length}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Inter",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const Flexible(
                  child: Text(
                    "Ai răspuns corect la toate întrebările testului",
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      );
    }

    if (quiz.questions[questionIndex].answearType == Answear.trueFalse) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: quiz.color.withAlpha(140),
                ),
                child: SvgPicture.asset(
                  quiz.icon,
                  width: 50,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SvgPicture.asset(
              "assets/illustrations/book.svg",
              width: Responsive.screenWidth / 1.5,
            ),
            const SizedBox(height: 30),
            Text(
              "ÎNTREBAREA ${questionIndex + 1} DIN ${quiz.questions.length}",
              style: const TextStyle(
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                fontFamily: "Inter",
                fontSize: 16,
                color: kDateTimeForegroundColor,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              quiz.questions[questionIndex].text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      QuizProvider quizProvider = Provider.of<QuizProvider>(context, listen: false);

                      if (quiz.questions[questionIndex].correctAnswear == 0) {
                        if (questionIndex + 1 == quiz.questions.length) {
                          setState(() {
                            completed = true;

                            if (quizProvider.quizes[quiz.id]! < questionIndex + 1) {
                              quizProvider.saveQuizProgress(quiz.id, questionIndex + 1);
                            }
                          });
                        }
                        setState(() {
                          questionIndex++;
                        });
                      } else {
                        setState(() {
                          failed = true;

                          if (quizProvider.quizes[quiz.id]! < questionIndex) {
                            quizProvider.saveQuizProgress(quiz.id, questionIndex);
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 10,
                      ),
                      backgroundColor: Colors.red[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Fals"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      QuizProvider quizProvider = Provider.of<QuizProvider>(context, listen: false);

                      if (quiz.questions[questionIndex].correctAnswear == 1) {
                        if (questionIndex + 1 == quiz.questions.length) {
                          setState(() {
                            completed = true;
                            if (quizProvider.quizes[quiz.id]! < questionIndex + 1) {
                              quizProvider.saveQuizProgress(quiz.id, questionIndex + 1);
                            }
                          });
                        }
                        setState(() {
                          questionIndex++;
                        });
                      } else {
                        setState(() {
                          failed = true;
                          if (quizProvider.quizes[quiz.id]! < questionIndex) {
                            quizProvider.saveQuizProgress(quiz.id, questionIndex);
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 10,
                      ),
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Adevărat"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      );
    }

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: quiz.color.withAlpha(140),
              ),
              child: SvgPicture.asset(
                quiz.icon,
                width: 50,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "ÎNTREBAREA ${questionIndex + 1} DIN ${quiz.questions.length}",
            style: const TextStyle(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              fontFamily: "Inter",
              fontSize: 16,
              color: kDateTimeForegroundColor,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            quiz.questions[questionIndex].text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 30),
          for (int i = 0; i < quiz.questions[questionIndex].answears!.length; i++)
            ChoiceCard(
              answearLetter: letters[i],
              answearText: quiz.questions[questionIndex].answears![i],
              selected: selectedAnswear == i ? true : false,
              backgroundColor: quiz.color,
              onTap: () {
                setState(() => selectedAnswear = i);
              },
            ),
          const Spacer(),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                QuizProvider quizProvider = Provider.of<QuizProvider>(context, listen: false);

                if (selectedAnswear != null) {
                  if (quiz.questions[questionIndex].correctAnswear == (selectedAnswear! + 1)) {
                    if (questionIndex + 1 == quiz.questions.length) {
                      setState(() {
                        completed = true;
                        if (quizProvider.quizes[quiz.id]! < questionIndex + 1) {
                          quizProvider.saveQuizProgress(quiz.id, questionIndex + 1);
                        }
                      });
                    }
                    setState(() {
                      questionIndex++;
                      selectedAnswear = null;
                    });
                  } else {
                    setState(() {
                      failed = true;
                      if (quizProvider.quizes[quiz.id]! < questionIndex ) {
                        quizProvider.saveQuizProgress(quiz.id, questionIndex);
                      }
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                elevation: 0,
                backgroundColor: quiz.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Următorul"),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: quiz.color,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: LinearProgressIndicator(
                        value: questionIndex / quiz.questions.length,
                        minHeight: 8,
                        color: Colors.white,
                        backgroundColor: Colors.white.withAlpha(100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Consumer<QuizProvider>(
                      builder: (context, quizProvider, _) {
                        int highScore = quizProvider.quizes[quiz.id]!;

                        return Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              width: 2,
                              color: Colors.orange,
                            ),
                            color: highScore >= questionIndex ? Colors.orange.withAlpha(125) : Colors.orangeAccent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/fire.svg",
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                highScore >= questionIndex ? highScore.toString() : questionIndex.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: Responsive.screenWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                    ),
                    child: CustomScrollView(
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        mainContent(context),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChoiceCard extends StatelessWidget {
  final String answearLetter;
  final String answearText;
  final Color backgroundColor;
  final bool selected;
  final void Function() onTap;

  const ChoiceCard({
    required this.answearLetter,
    required this.answearText,
    required this.backgroundColor,
    required this.selected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: kBackgroundColor,
            ),
            borderRadius: BorderRadius.circular(10),
            color: selected ? backgroundColor.withAlpha(140) : null,
          ),
          child: Text(
            "$answearLetter. $answearText",
            style: const TextStyle(),
          ),
        ),
      ),
    );
  }
}
