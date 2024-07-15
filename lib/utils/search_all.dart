import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:visit_braila/controllers/hotel_controller.dart';
import 'package:visit_braila/controllers/restaurant_controller.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/models/hotel_model.dart';
import 'package:visit_braila/models/restaurant_model.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
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
  "fără",
  "sub",
  "pentru",
  "prin",
  "si",
  "și",
  "peste",
];

class SearchAll extends SearchDelegate<String> {
  final SightController sightController = SightController();
  final TourController tourController = TourController();
  final RestaurantController restaurantController = RestaurantController();
  final HotelController hotelController = HotelController();

  List<Sight> allSights = [];
  List<Tour> allTours = [];
  List<Restaurant> allRestaurants = [];
  List<Hotel> allHotels = [];
  List data = [];

  Future<List> fetchData() async {
    try {
      allSights = await sightController.fetchSights();
      allTours = await tourController.fetchTours();
      allRestaurants = await restaurantController.fetchRestaurants();
      allHotels = await hotelController.fetchHotels();

      data.clear();
      data.addAll(allSights);
      data.addAll(allTours);
      data.addAll(allRestaurants);
      data.addAll(allHotels);

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

    for (String word in query
        .trim()
        .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
        .toLowerCase()
        .split(" ")) {
      if (word == "") {
        continue;
      }
      matches.addAll(
        word.allMatches(resultName
            .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
            .toLowerCase()),
      );
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
      if (word == "") {
        return;
      }

      if (prepositions.contains(word)) {
        return;
      }

      filteredData.addAll(
        data.where(
          (entry) =>
              entry.name
                  .toString()
                  .toLowerCase()
                  .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
                  .split(" ")
                  .any((entryWord) => entryWord.startsWith(word)) ||
              entry.name.toString().toLowerCase().split(" ").any((entryWord) => entryWord.startsWith(word)),
        ),
      );
    });

    return filteredData.toList();
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List filteredData = getResults(snapshot.data!);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, top: 12),
                  child: Text(
                    filteredData.length != 1
                        ? "${filteredData.length} rezultate găsite"
                        : "${filteredData.length} rezultat găsit",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: kDimmedForegroundColor,
                          fontSize: 14,
                        ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: filteredData.length,
                  (context, index) {
                    var result = filteredData[index];

                    switch (result.runtimeType) {
                      case Sight:
                        return resultListTile(
                          pushTo: () => Navigator.pushNamed(context, "/sight", arguments: result),
                          icon: "assets/icons/building.svg",
                          name: result.name,
                        );
                      case Tour:
                        return resultListTile(
                          pushTo: () => Navigator.pushNamed(context, "/tour", arguments: result),
                          icon: "assets/icons/route.svg",
                          name: result.name,
                        );
                      case Restaurant:
                        return resultListTile(
                          pushTo: () => Navigator.pushNamed(context, "/restaurant", arguments: result),
                          icon: "assets/icons/restaurant-outline.svg",
                          name: result.name,
                        );
                      case Hotel:
                        return resultListTile(
                          pushTo: () => Navigator.pushNamed(context, "/hotel", arguments: result),
                          icon: "assets/icons/bed-outline.svg",
                          name: result.name,
                        );
                      default:
                        return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          );
        } else if (snapshot.hasError && snapshot.error is HttpException) {
          showErrorDialog(context);
        }

        return const LoadingSpinner();
      },
    );
  }

  Widget resultListTile({
    required void Function() pushTo,
    required String icon,
    required String name,
  }) {
    return ListTile(
      onTap: pushTo,
      leading: SvgPicture.asset(
        icon,
        height: 24,
        colorFilter: const ColorFilter.mode(kPrimaryColor, BlendMode.srcIn),
      ),
      title: RichText(
        text: TextSpan(
          children: highlightedText(name.toString()),
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
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
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: kDimmedForegroundColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
