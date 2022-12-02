import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visit_braila/controllers/about_controller.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/url_constants.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/html_description.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> with TickerProviderStateMixin {
  String paragraph1 = "";
  String paragraph2 = "";
  Map<String, dynamic> contact = {"director": "", "phone": "", "email": ""};

  AboutController aboutController = AboutController();

  bool isLoading = true;

  late final AnimationController fadeAnimationController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

  late final Animation<double> fadeAnimation = CurvedAnimation(
    parent: fadeAnimationController,
    curve: const Interval(0, 0.5),
  );

  @override
  void initState() {
    super.initState();

    getAboutData();
  }

  void getAboutData() async {
    try {
      paragraph1 = await aboutController.fetchAboutParagraph1();
      paragraph2 = await aboutController.fetchAboutParagraph2();
      contact = await aboutController.fetchContactDetails();

      setState(() => isLoading = false);
      fadeAnimationController.forward();
    } on HttpException {
      showErrorDialog(context);
    }
  }

  @override
  void dispose() {
    fadeAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 0,
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
              expandedHeight: Responsive.safeBlockVertical * 30,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  "assets/images/bjpi.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(16),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: topOnlyShadows,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: const SizedBox(height: 16),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: isLoading
                  ? SizedBox(
                      height: Responsive.safeBlockVertical * 36,
                      child: const LoadingSpinner(),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                        top: 8,
                        left: 18,
                        right: 18,
                      ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: fadeAnimation,
                          curve: const Interval(0.6, 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Biblioteca Județeană \"Panait Istrati\" Brăila",
                              style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            HtmlDescription(
                              data: paragraph1,
                              shrink: false,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: Divider(
                                thickness: 1.1,
                              ),
                            ),
                            Text(
                              "Despre Visit Brăila",
                              style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            HtmlDescription(
                              data: paragraph2,
                              shrink: false,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              child: Divider(
                                thickness: 1.1,
                              ),
                            ),
                            Text(
                              "Contact",
                              style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/user.svg",
                                  width: 20,
                                  color: kForegroundColor,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Director: ",
                                  style: TextStyle(
                                    fontFamily: labelFont,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  contact['director'],
                                  style: const TextStyle(
                                    fontFamily: labelFont,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/phone.svg",
                                  width: 20,
                                  color: kForegroundColor,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Telefon: ",
                                  style: TextStyle(
                                    fontFamily: labelFont,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => openTel(contact['phone']),
                                  child: Text(
                                    contact['phone'],
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: labelFont,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/mail.svg",
                                  width: 20,
                                  color: kForegroundColor,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Email: ",
                                  style: TextStyle(
                                    fontFamily: labelFont,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => openEmail(contact['email']),
                                  child: Text(
                                    contact['email'],
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: labelFont,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                                boxShadow: shadowLg,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Autorul aplicației",
                                    style: TextStyle(
                                      fontFamily: labelFont,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: lightGrey,
                                            child: const Text(
                                              "MV",
                                              style: TextStyle(
                                                fontFamily: labelFont,
                                                color: kForegroundColor,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          const Text(
                                            "Mario Vlaviano",
                                            style: TextStyle(
                                              fontFamily: labelFont,
                                              color: kForegroundColor,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => openBrowserURL(authorFacebookUrl),
                                            child: SvgPicture.asset(
                                              "assets/icons/logo-facebook.svg",
                                              width: 26,
                                              color: kForegroundColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          GestureDetector(
                                            onTap: () => openBrowserURL(authorInstagramUrl),
                                            child: SvgPicture.asset(
                                              "assets/icons/logo-instagram.svg",
                                              width: 26,
                                              color: kForegroundColor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          GestureDetector(
                                            onTap: () => openBrowserURL(authorGithubUrl),
                                            child: SvgPicture.asset(
                                              "assets/icons/logo-github.svg",
                                              width: 26,
                                              color: kForegroundColor,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
