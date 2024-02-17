import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visit_braila/models/quiz_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';

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
                      const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: QuizzCategoryCard(
                          title: "Cultură generală",
                          icon: "assets/icons/mortarboard.svg",
                          iconBgColor: Color(0xff4dabf7),
                          length: 100,
                        ),
                      ),
                      for (Quiz quiz in quizes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: QuizzCategoryCard(
                            quiz: quiz,
                            title: quiz.title,
                            icon: quiz.icon,
                            iconBgColor: quiz.color,
                            length: quiz.questions.length,
                          ),
                        ),
                      const Text(
                        "Memorie vizuală",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                          fontSize: 24,
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

  const QuizzCategoryCard({
    this.quiz,
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.length,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/quiz", arguments: quiz),
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
                    fontFamily: "Inter",
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Text(
                  "0 din $length întrebări",
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              CupertinoIcons.chevron_right,
              color: kPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
