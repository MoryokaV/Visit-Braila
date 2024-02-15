import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                "assets/icons/learn.svg",
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Testează-ți cunoștințele",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "CATEGORII",
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Inter",
                          fontSize: 18,
                          color: kDateTimeForegroundColor,
                        ),
                      ),
                      SizedBox(height: 14),
                      QuizzCategoryCard(
                        title: "Cultură generală",
                        icon: "assets/icons/mortarboard.svg",
                        iconBgColor: Color(0xff4dabf7),
                      ),
                      SizedBox(height: 10),
                      QuizzCategoryCard(
                        title: "Istorie",
                        icon: "assets/icons/history.svg",
                        iconBgColor: Color(0xffff8787),
                      ),
                      SizedBox(height: 10),
                      QuizzCategoryCard(
                        title: "Personalități",
                        icon: "assets/icons/people.svg",
                        iconBgColor: Color(0xffa9e34b),
                      ),
                      SizedBox(height: 10),
                      QuizzCategoryCard(
                        title: "Geografie",
                        icon: "assets/icons/geography.svg",
                        iconBgColor: Color(0xffffc078),
                      ),
                      SizedBox(height: 10),
                      QuizzCategoryCard(
                        title: "Religie",
                        icon: "assets/icons/cross.svg",
                        iconBgColor: Color(0xffced4da),
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
  final String title;
  final String icon;
  final Color iconBgColor;

  const QuizzCategoryCard({
    required this.title,
    required this.icon,
    required this.iconBgColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: null,
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
                color: iconBgColor,
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
                const Text(
                  "13 din 94 întrebări",
                  style: TextStyle(
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
