import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:visit_braila/controllers/personality_controller.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/personality_model.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/search_all.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';
import 'package:visit_braila/widgets/search_list_field.dart';

class AllPersonalitiesView extends StatefulWidget {
  const AllPersonalitiesView({super.key});

  @override
  State<AllPersonalitiesView> createState() => _AllPersonalitiesViewState();
}

class _AllPersonalitiesViewState extends State<AllPersonalitiesView> {
  final PersonalityController personalityController = PersonalityController();
  bool isLoading = true;
  List<Personality> personalities = [];
  List<String?> sightNames = [];
  List<Personality> filteredData = [];

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    try {
      personalities = await personalityController.fetchPersonalities();
      filteredData = personalities;

      for (Personality personality in personalities) {
        if (personality.sightLink != null) {
          Sight? sight = await SightController().findSight(personality.sightLink!);

          if (sight != null) {
            sightNames.add(sight.name);
          } else {
            sightNames.add(null);
          }
        }
      }
    } on HttpException {
      if (mounted) {
        showErrorDialog(context);
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void updateList(String query) {
    filteredData = [];

    query.trim().toLowerCase().split(" ").forEach((word) {
      if (word == "") {
        return;
      }

      if (prepositions.contains(word)) {
        return;
      }

      filteredData.addAll(
        personalities.where(
          (personality) =>
              (personality.name
                      .toString()
                      .toLowerCase()
                      .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
                      .split(" ")
                      .any((entryWord) => entryWord.startsWith(word)) ||
                  personality.name
                      .toString()
                      .toLowerCase()
                      .split(" ")
                      .any((entryWord) => entryWord.startsWith(word))) &&
              !filteredData.contains(personality),
        ),
      );
    });

    if (query.trim().isEmpty) {
      filteredData.addAll(personalities);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Personalități ",
              ),
              TextSpan(
                text: "brăilene",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.adaptive.arrow_back,
            color: kForegroundColor,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const LoadingSpinner()
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 14,
                        right: 14,
                        top: 10,
                      ),
                      child: Column(
                        children: [
                          SearchListField(
                            onChanged: updateList,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 14, right: 14, bottom: 20),
                    sliver: SliverMasonryGrid.count(
                      childCount: filteredData.length,
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemBuilder: (context, index) {
                        return PersonalityCard(
                          personality: filteredData[index],
                          sightName: sightNames[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class PersonalityCard extends StatelessWidget {
  final Personality personality;
  final String? sightName;

  const PersonalityCard({
    super.key,
    required this.personality,
    this.sightName,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: personality.id,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/personality", arguments: {
            "personality": personality,
            "sightName": sightName,
          }),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                CachedApiImage(
                  imageUrl: personality.images[personality.primaryImage - 1],
                  cacheWidth: Responsive.screenWidth / 2,
                ),
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                    ),
                    child: Text(
                      personality.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
