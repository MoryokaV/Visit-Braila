import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/providers/quiz_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class ImageQuizView extends StatefulWidget {
  const ImageQuizView({super.key});

  @override
  State<ImageQuizView> createState() => _ImageQuizViewState();
}

class _ImageQuizViewState extends State<ImageQuizView> {
  int questionIndex = 0;

  final SightController sightController = SightController();
  List<Sight> sights = [];

  bool isLoading = true;

  @override
  void initState() {
    fetchData();

    super.initState();
  }

  void fetchData() async {
    try {
      sights = (await sightController.fetchSights()).where((sight) {
        if (sight.tags.contains("Istorie") ||
            sight.tags.contains("Religie") ||
            sight.tags.contains("Arhitectură") ||
            sight.tags.contains("Cultură")) {
          return true;
        }

        return false;
      }).toList();
      sights.shuffle();
    } on HttpException {
      if (mounted) {
        showErrorDialog(context);
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget bottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: Responsive.screenWidth / 16,
        right: Responsive.screenWidth / 16,
        top: 12,
        bottom: Responsive.safePaddingBottom != 0 ? Responsive.safePaddingBottom : 14,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: kDimmedForegroundColor.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<QuizProvider>(
                  builder: (context, quizProvider, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/fire.svg",
                        width: 18,
                        colorFilter: ColorFilter.mode(
                          quizProvider.quizes['img']! >= questionIndex ? kForegroundColor : Colors.orange[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${quizProvider.quizes['img']}",
                        style: TextStyle(
                          fontFamily: "Inter",
                          color: quizProvider.quizes['img']! >= questionIndex ? kForegroundColor : Colors.orange[700]!,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: questionIndex / sights.length,
                  minHeight: 8,
                  color: kPrimaryColor,
                  backgroundColor: kPrimaryColor.withAlpha(100),
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
          SizedBox(width: Responsive.safeBlockHorizontal * 6),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 34,
              ),
            ),
            child: const Text(
              "Răspunde",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: isLoading ? null : bottomBar(),
        body: SafeArea(
          top: false,
          child: isLoading
              ? const LoadingSpinner()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CachedApiImage(
                            imageUrl: sights[questionIndex].images[sights[questionIndex].primaryImage - 1],
                            width: Responsive.screenWidth,
                            height: Responsive.safeBlockVertical * 45,
                            cacheHeight: Responsive.safeBlockVertical * 45,
                            blurhash: sights[questionIndex].primaryImageBlurhash,
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black45,
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/zoom-in.svg",
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 1,
                                  icon: const Icon(
                                    CupertinoIcons.chevron_left,
                                    size: 24,
                                    color: kDateTimeForegroundColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "ÎNTREBAREA ${questionIndex + 1} DIN ${sights.length}",
                                  style: const TextStyle(
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Inter",
                                    fontSize: 16,
                                    color: kDateTimeForegroundColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              "Ghicește locul, clădirea sau strada!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              decoration: InputDecoration(
                                focusColor: kPrimaryColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: 'Introdu denumirea aici',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
