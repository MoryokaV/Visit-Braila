import 'dart:io';
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

const Map<String, String> diacriticsMapping = {
  "Ă": "A",
  "ă": "a",
  "Â": "A",
  "â": "a",
  "Î": "I",
  "î": "i",
  "Ș": "S",
  "ș": "s",
  "Ț": "T",
  "ț": "t",
};

const List<String> prepositions = [
  "de",
  "pe",
  "cu",
  "despre",
  "în",
  "in",
  "a",
  "al",
  "la",
  "lui",
  "fără",
  "sub",
  "pentru",
  "prin",
  "care",
  "din"
];

const List<String> symbols = [];

class ImageQuizView extends StatefulWidget {
  const ImageQuizView({super.key});

  @override
  State<ImageQuizView> createState() => _ImageQuizViewState();
}

class _ImageQuizViewState extends State<ImageQuizView> {
  int questionIndex = 0;
  int score = 0;
  bool completed = false;
  bool failed = false;

  final SightController sightController = SightController();
  List<Sight> sights = [];

  bool isLoading = true;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    fetchData();

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();

    super.dispose();
  }

  void fetchData() async {
    try {
      List<Sight> data = await sightController.fetchSights();

      List<Sight> cultura = data
          .where(
            (sight) => sight.tags.contains("Cultură"),
          )
          .toList();
      cultura.shuffle();

      List<Sight> religie = data
          .where(
            (sight) => sight.tags.contains("Religie") && !cultura.contains(sight),
          )
          .toList();
      religie.shuffle();

      List<Sight> arhitectura = data
          .where(
            (sight) => sight.tags.contains("Arhitectură") && !cultura.contains(sight) && !religie.contains(sight),
          )
          .toList();
      arhitectura.shuffle();

      List<Sight> istorie = data
          .where(
            (sight) =>
                sight.tags.contains("Istorie") &&
                !cultura.contains(sight) &&
                !religie.contains(sight) &&
                !arhitectura.contains(sight),
          )
          .toList();
      istorie.shuffle();

      sights.addAll(cultura);
      sights.addAll(religie);
      sights.addAll(arhitectura);
      sights.addAll(istorie);
    } on HttpException {
      if (mounted) {
        showErrorDialog(context);
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void checkAnswear() {
    String answear = sights[questionIndex].name;
    String query = textEditingController.text;

    answear = answear
        .toLowerCase()
        .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
        .replaceAll('“', '')
        .replaceAll('”', '')
        .replaceAll('"', '');

    query = query
        .trim()
        .toLowerCase()
        .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
        .replaceAll('“', '')
        .replaceAll('”', '')
        .replaceAll('"', '');

    int matches = 0;

    answear.split(" ").forEach((word) {
      if (prepositions.contains(word)) {
        return;
      }

      bool match = query.split(" ").any((queryWord) => queryWord == word);
      if (match) {
        matches++;
      }
    });

    QuizProvider quizProvider = Provider.of<QuizProvider>(context, listen: false);

    if (matches > 0) {
      score += matches;

      if (questionIndex + 1 == sights.length) {
        setState(() {
          completed = true;

          if (quizProvider.quizes['img']! < score) {
            quizProvider.saveQuizProgress('img', score);
          }
        });
      } else {
        setState(() {
          textEditingController.text = "";
          questionIndex++;
        });
      }
    } else {
      setState(() {
        failed = true;
        if (quizProvider.quizes['img']! < score) {
          quizProvider.saveQuizProgress('img', score);
        }
      });
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
                Consumer<QuizProvider>(builder: (context, quizProvider, _) {
                  int highScore = quizProvider.quizes["img"]!;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/fire.svg",
                        width: 18,
                        colorFilter: ColorFilter.mode(
                          highScore >= score ? kForegroundColor : Colors.orange[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        score.toString(),
                        style: TextStyle(
                          fontFamily: "Inter",
                          color: highScore >= score ? kForegroundColor : Colors.orange[700]!,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }),
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
            onPressed: !failed && !completed ? checkAnswear : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 34,
              ),
            ),
            child: Text(
              !failed && !completed ? "Răspunde" : "Înapoi",
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mainContent() {
    if (completed) {
      return Column(
        children: [
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
          const Text(
            "Ai parcurs toate locurile din Brăila. Antrenează-te pentru a obține punctajul maxim.",
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
                        value: questionIndex / sights.length,
                        color: kPrimaryColor,
                        backgroundColor: kPrimaryColor.withAlpha(50),
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Center(
                      child: Text(
                        "$questionIndex/${sights.length}",
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
        ],
      );
    }

    if (failed) {
      return Column(
        children: [
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
          Text(
            "Răspuns corect: ${sights[questionIndex].name}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
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
                        value: questionIndex / sights.length,
                        color: kPrimaryColor,
                        backgroundColor: kPrimaryColor.withAlpha(50),
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Center(
                      child: Text(
                        "$questionIndex/${sights.length}",
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
                  "Ai acumulat $score puncte în $questionIndex din ${sights.length} întrebări",
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 1,
              icon: Icon(
                Icons.adaptive.arrow_back,
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
          controller: textEditingController,
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
        const SizedBox(height: 10),
        if (questionIndex > 0)
          Text(
            "Răspunsul anterior: ${sights[questionIndex - 1].name}",
            style: const TextStyle(
              color: kDimmedForegroundColor,
              fontSize: 14,
            ),
          )
      ],
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
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/quizgallery',
                          arguments: sights[questionIndex].images[sights[questionIndex].primaryImage - 1],
                        ),
                        child: Stack(
                          children: [
                            CachedApiImage(
                              imageUrl: sights[questionIndex].images[sights[questionIndex].primaryImage - 1],
                              width: Responsive.screenWidth,
                              height: Responsive.safeBlockVertical * 45,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 28,
                        ),
                        child: mainContent(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
