import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class SearchAll extends SearchDelegate<String> {
  final SightController sightController = SightController();
  final TourController tourController = TourController();

  List<Tour> allTours = [];
  List<Sight> allSights = [];
  List data = [];

  Future<List> fetchData() async {
    try {
      allTours = await tourController.fetchTours();
      allSights = await sightController.fetchSights();

      data.addAll(allSights);
      data.addAll(allTours);

      return data;
    } on HttpException {
      rethrow;
    }
  }

  @override
  String? get searchFieldLabel => "Caută";

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
        fontFamily: labelFont,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: kForegroundColor,
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = "",
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.adaptive.arrow_back),
      onPressed: () => close(context, ""),
    );
  }

  List<TextSpan> highlightedText(String resultName) {
    final List<Match> matches = [];

    for (String word in query.trim().toLowerCase().split(" ")) {
      matches.addAll(word.allMatches(resultName.toLowerCase()));
    }

    if (matches.isEmpty) {
      return [
        TextSpan(text: resultName),
      ];
    }

    int lastMatchEnd = 0;
    final List<TextSpan> children = [];

    for (final match in matches) {
      children.add(
        TextSpan(
          text: resultName.substring(lastMatchEnd, match.start),
        ),
      );
      children.add(
        TextSpan(
          text: resultName.substring(match.start, match.end),
          style: const TextStyle(
            color: kBlackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    children.add(
      TextSpan(
        text: resultName.substring(lastMatchEnd, resultName.length),
      ),
    );

    return children;
  }

  List getResults(var data) {
    Set filteredData = {};

    query.trim().toLowerCase().split(" ").forEach((word) {
      filteredData.addAll(
        data.where(
          (entry) => entry.name.toString().toLowerCase().contains(word),
        ),
      );
    });

    return filteredData.toList();
  }

  @override
  Widget buildResults(BuildContext context) {
    allSights = [];
    allTours = [];
    data = [];

    return FutureBuilder<List>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List filteredData = getResults(snapshot.data!);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 12),
                  child: Text(
                    filteredData.length != 1
                        ? "${filteredData.length} rezultate găsite"
                        : "${filteredData.length} rezultat găsit",
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: kDimmedForegroundColor,
                          fontSize: 14,
                        ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    var result = filteredData[index];
                    bool isSight = allSights.contains(result);

                    return ListTile(
                      onTap: () =>
                          Navigator.pushNamed(context, isSight ? "/sight" : "/tour", arguments: filteredData[index]),
                      leading: SvgPicture.asset(
                        isSight ? "assets/icons/building.svg" : "assets/icons/route.svg",
                        height: 24,
                        color: kPrimaryColor,
                      ),
                      title: RichText(
                          text: TextSpan(
                        children: highlightedText(result.name.toString()),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      )),
                    );
                  },
                ),
              ],
            ),
          );
        } else if (snapshot.hasError && snapshot.error is HttpException) {
          showErrorDialog(context);
        }

        return const LoadingSpinner();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            "assets/animations/find.json",
            height: Responsive.safeBlockVertical * 30,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Ești în căutare de noi activități?",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: kDimmedForegroundColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
