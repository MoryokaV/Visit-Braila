import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:visit_braila/controllers/fitness_controller.dart';
import 'package:visit_braila/models/fitness_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/search_all.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';
import 'package:visit_braila/widgets/search_list_field.dart';

class AllFitnessView extends StatefulWidget {
  const AllFitnessView({super.key});

  @override
  State<AllFitnessView> createState() => _AllFitnessViewState();
}

class _AllFitnessViewState extends State<AllFitnessView> {
  final FitnessController fitnessController = FitnessController();
  bool isLoading = true;
  List<Fitness> fitness = [];
  List<Fitness> filteredData = [];

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    try {
      fitness = await fitnessController.fetchFitness();
      filteredData = fitness;
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
        fitness.where(
          (item) =>
              (item.name
                      .toString()
                      .toLowerCase()
                      .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
                      .split(" ")
                      .any((entryWord) => entryWord.startsWith(word)) ||
                  item.name.toString().toLowerCase().split(" ").any((entryWord) => entryWord.startsWith(word))) &&
              !filteredData.contains(item),
        ),
      );
    });

    if (query.trim().isEmpty) {
      filteredData.addAll(fitness);
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
                text: "Fitness ",
              ),
              TextSpan(
                text: "&",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const TextSpan(
                text: " Wellness",
              ),
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
                        return FitnessCard(fitness: filteredData[index]);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class FitnessCard extends StatelessWidget {
  final Fitness fitness;

  const FitnessCard({
    super.key,
    required this.fitness,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: fitness.id,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/fitness", arguments: fitness),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                CachedApiImage(
                  imageUrl: fitness.images[fitness.primaryImage - 1],
                  cacheWidth: Responsive.screenWidth / 2,
                ),
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                    ),
                    child: Text(
                      fitness.name,
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
