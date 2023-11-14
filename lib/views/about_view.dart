import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visit_braila/controllers/about_controller.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/url_constants.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/html_description.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> with TickerProviderStateMixin {
  Map<String, dynamic> data = {
    "paragraph1": "",
    "paragraph2": "",
    "oraganization1": "",
    "oraganization2": "",
    "phone": "",
    "email": "",
    "website1": "",
    "website2": "",
    "facebook1": "",
    "facebook2": "",
    "cover_image": "",
    "cover_image_blurhash": "",
  };
  AboutController aboutController = AboutController();

  late final AnimationController fadeAnimationController;
  late final Animation<double> fadeAnimation;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fadeAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    fadeAnimation = CurvedAnimation(
      parent: fadeAnimationController,
      curve: const Interval(0, 0.5),
    );

    getAboutData();
  }

  void getAboutData() async {
    try {
      data = await aboutController.fetchAboutData();

      if (mounted) {
        setState(() => isLoading = false);
        fadeAnimationController.forward();
      }
    } on HttpException {
      if (mounted) {
        showErrorDialog(context);
      }
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
                background: data['cover_image'] != ""
                    ? CachedApiImage(
                        imageUrl: "$baseUrl${data['cover_image']}",
                        cacheWidth: Responsive.screenWidth,
                        blurhash: data['cover_image_blurhash'],
                      )
                    : Container(color: kDimmedForegroundColor),
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
            isLoading
                ? const SliverFillRemaining(
                    child: LoadingSpinner(),
                  )
                : SliverToBoxAdapter(
                    child: Padding(
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
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(text: "Despre "),
                                  TextSpan(
                                    text: "Visit Brăila",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                                style:
                                    Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 14),
                            HtmlDescription(
                              data: data["paragraph2"]!,
                              shrink: false,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(thickness: 1.1),
                            ),
                            Text(
                              "Instituții partenere",
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 14),
                            HtmlDescription(
                              data: data["paragraph1"]!,
                              shrink: false,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(thickness: 1.1),
                            ),
                            Text(
                              "Contact",
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/user.svg",
                                  width: 20,
                                  colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
                                ),
                                const Text(
                                  "Organizație: ",
                                  style: TextStyle(
                                    fontFamily: labelFont,
                                  ),
                                ),
                                Text(
                                  "${data['organization1']!}, ${data['organization2']!}",
                                  style: const TextStyle(
                                    fontFamily: labelFont,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/phone.svg",
                                  width: 20,
                                  colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
                                ),
                                const Text(
                                  "Telefon: ",
                                  style: TextStyle(
                                    fontFamily: labelFont,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openTel(data['phone']!),
                                  child: Text(
                                    data['phone']!,
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
                            const SizedBox(height: 10),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/mail.svg",
                                  width: 20,
                                  colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
                                ),
                                const Text(
                                  "Email: ",
                                  style: TextStyle(
                                    fontFamily: labelFont,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openEmail(data['email']!),
                                  child: Text(
                                    data['email']!,
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
                            const SizedBox(height: 10),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/link-outline.svg",
                                  width: 20,
                                  colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
                                ),
                                const Text(
                                  "Website oficial: ",
                                  style: TextStyle(
                                    fontFamily: labelFont,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openBrowserURL(data['website1']!),
                                  child: Text(
                                    data['website1']!,
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: labelFont,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openBrowserURL(data['website2']!),
                                  child: Text(
                                    data['website2']!,
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
                            const SizedBox(height: 10),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/link-outline.svg",
                                  width: 20,
                                  colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
                                ),
                                const Text(
                                  "Facebook: ",
                                  style: TextStyle(
                                    fontFamily: labelFont,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openBrowserURL(data['facebook1']!),
                                  child: Text(
                                    data['facebook1']!,
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: labelFont,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => openBrowserURL(data['facebook2']!),
                                  child: Text(
                                    data['facebook2']!,
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
                            const SizedBox(height: 22),
                            InkWell(
                              onTap: () => openBrowserURL(privacyPolicyUrl),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: kBackgroundColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Politica de confidențialitate",
                                      style: TextStyle(
                                        fontFamily: labelFont,
                                      ),
                                    ),
                                    Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
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
                                    "Dezvoltatorul aplicației",
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
                                              colorFilter: const ColorFilter.mode(kForegroundColor, BlendMode.srcIn),
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
                                              colorFilter: const ColorFilter.mode(kForegroundColor, BlendMode.srcIn),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          GestureDetector(
                                            onTap: () => openBrowserURL(authorLinkedInUrl),
                                            child: SvgPicture.asset(
                                              "assets/icons/logo-linkedin.svg",
                                              width: 26,
                                              colorFilter: const ColorFilter.mode(kForegroundColor, BlendMode.srcIn),
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
