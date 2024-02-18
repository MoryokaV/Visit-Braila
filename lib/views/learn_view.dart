import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/models/quiz_model.dart';
import 'package:visit_braila/providers/quiz_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';

class LearnView extends StatelessWidget {
  const LearnView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 8,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                "assets/illustrations/learn.svg",
                width: Responsive.screenWidth,
                height: Responsive.safeBlockVertical * 30,
                fit: BoxFit.cover,
              ),
              Container(
                width: Responsive.screenWidth,
                constraints: BoxConstraints(
                  minHeight: Responsive.screenHeight - Responsive.safeBlockVertical * 30,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Testează-ți cunoștințele",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "CATEGORII",
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                          fontSize: 18,
                          color: kDateTimeForegroundColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: QuizzCategoryCard(
                          title: "Cultură generală",
                          icon: "assets/icons/mortarboard.svg",
                          iconBgColor: const Color(0xff4dabf7),
                          length: quizes.map((q) => q.questions.length).toList().reduce((v, e) => v + e),
                          id: "quiz0",
                        ),
                      ),
                      for (Quiz quiz in quizes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: QuizzCategoryCard(
                            quiz: quiz,
                            id: quiz.id,
                            title: quiz.title,
                            icon: quiz.icon,
                            iconBgColor: quiz.color,
                            length: quiz.questions.length,
                          ),
                        ),
                      const SizedBox(height: 14),
                      const Text(
                        "Memorie vizuală",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/imgquiz"),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedAssetImage(
                                "assets/images/walk.png",
                                width: Responsive.screenWidth,
                                height: Responsive.safeBlockVertical * 20,
                                cacheHeight: Responsive.safeBlockVertical * 20,
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/fire.svg",
                                          width: 22,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Consumer<QuizProvider>(
                                          builder: (context, quizProvider, _) => Text(
                                            "${quizProvider.quizes['img']}",
                                            style: const TextStyle(
                                              fontFamily: "Inter",
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      "Recunoaște locurile",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizzCategoryCard extends StatelessWidget {
  final Quiz? quiz;
  final String title;
  final String icon;
  final Color iconBgColor;
  final int length;
  final String id;

  const QuizzCategoryCard({
    this.quiz,
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.length,
    required this.id,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) => GestureDetector(
        onTap: quizProvider.quizes[id]! < length ? () => Navigator.pushNamed(context, "/quiz", arguments: quiz) : null,
        child: Container(
          width: Responsive.screenWidth,
          height: Responsive.safeBlockVertical * 11,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kBackgroundColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: Responsive.safeBlockVertical * 11 - 16,
                height: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: iconBgColor.withOpacity(0.75),
                ),
                child: SvgPicture.asset(
                  icon,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${quizProvider.quizes[id]} din $length întrebări",
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                quizProvider.quizes[id]! < length ? CupertinoIcons.chevron_right : CupertinoIcons.checkmark_circle_fill,
                color: kPrimaryColor,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
