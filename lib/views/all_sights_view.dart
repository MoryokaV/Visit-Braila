import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/like_animation.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';
import 'package:visit_braila/widgets/search_list_field.dart';

class AllSightsView extends StatefulWidget {
  const AllSightsView({super.key});

  @override
  State<AllSightsView> createState() => _AllSightsViewState();
}

class _AllSightsViewState extends State<AllSightsView> {
  final SightController sightController = SightController();
  List<Sight> sights = [];
  List<Sight> filteredData = [];

  List<String> tags = [];
  int selectedIndex = 0;

  bool isLoading = true;
  bool disableHero = false;

  String currentQuery = "";

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    tags.add("Toate");
    tags.addAll(await sightController.fetchAllTags());

    sights = await sightController.fetchSights();
    filteredData = sights;

    setState(() {
      isLoading = false;
    });
  }

  void updateList(String query) {
    filteredData = [];

    query.trim().toLowerCase().split(" ").forEach((word) {
      filteredData.addAll(
        sights.where((sight) {
          if (sight.name.toString().toLowerCase().contains(word) && !filteredData.contains(sight)) {
            if (selectedIndex == 0) {
              return true;
            } else if (selectedIndex != 0 && sight.tags.contains(tags[selectedIndex])) {
              return true;
            } else {
              return false;
            }
          }

          return false;
        }),
      );
    });

    setState(() {
      currentQuery = query;
    });
  }

  void setTag(int index) {
    setState(() {
      selectedIndex = index;
      updateList(currentQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() => disableHero = true);

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kBackgroundColor,
          elevation: 0,
          titleSpacing: 0,
          title: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Explorează ",
                ),
                TextSpan(
                  text: "Obiective",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
              style: Theme.of(context).textTheme.headline4!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              setState(() => disableHero = true);

              Navigator.pop(context);
            },
            icon: Icon(
              Icons.adaptive.arrow_back,
              color: kForegroundColor,
            ),
          ),
        ),
        body: SafeArea(
          child: isLoading
              ? const LoadingSpinner()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 24,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SearchListField(
                            onChanged: updateList,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            itemCount: tags.length,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                width: 10,
                              );
                            },
                            itemBuilder: (context, index) {
                              bool isSelected = selectedIndex == index;

                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: isSelected ? kBlackColor : lightGrey,
                                  foregroundColor: isSelected ? Colors.white : kForegroundColor,
                                  textStyle: Theme.of(context).textTheme.button!.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: isSelected ? Colors.white : kForegroundColor,
                                      ),
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: () => setTag(index),
                                child: Text(
                                  tags[index],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredData.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 25);
                            },
                            itemBuilder: (context, index) {
                              return SightCard(
                                sight: filteredData[index],
                                heroTag: disableHero ? index.toString() : filteredData[index].id,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class SightCard extends StatelessWidget {
  final Sight sight;
  final String heroTag;

  SightCard({
    super.key,
    required this.sight,
    required this.heroTag,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/sight", arguments: sight),
      child: Column(
        children: [
          Hero(
            tag: heroTag,
            child: Container(
              height: Responsive.safeBlockVertical * 35,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                boxShadow: const [bottomShadowMd],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        sight.images[sight.primaryImage - 1],
                        fit: BoxFit.cover,
                        height: double.infinity,
                      ),
                      if (sight.tags.isNotEmpty)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: double.infinity,
                                color: Colors.black.withOpacity(0.25),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        sight.tags.join(", "),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sight.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kBlackColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/map-pin.svg",
                          width: 22,
                          color: kBlackColor,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Text(
                          "N/A km",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: LikeAnimation(
                  key: likeAnimationKey,
                  child: Consumer<Wishlist>(
                    builder: (context, wishlist, _) {
                      return IconButton(
                        splashRadius: 1,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          wishlist.toggleSightWishState(sight.id);
                          likeAnimationKey.currentState!.animate();
                        },
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          wishlist.items['sights']!.contains(sight.id)
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: wishlist.items['sights']!.contains(sight.id)
                              ? Theme.of(context).colorScheme.secondary
                              : kDisabledIconColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
