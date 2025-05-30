import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/restaurant_controller.dart';
import 'package:visit_braila/models/restaurant_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/services/location_service.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/search_all.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/like_animation.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';
import 'package:visit_braila/widgets/search_list_field.dart';
import 'package:visit_braila/widgets/tags_listview.dart';
import 'package:flutter/material.dart';

class AllRestaurantsView extends StatefulWidget {
  const AllRestaurantsView({super.key});

  @override
  State<AllRestaurantsView> createState() => _AllRestaurantsViewState();
}

class _AllRestaurantsViewState extends State<AllRestaurantsView> {
  final RestaurantController restaurantController = RestaurantController();
  List<Restaurant> restaurants = [];
  List<Restaurant> filteredData = [];

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
    try {
      tags.add("Toate");
      tags.addAll(await restaurantController.fetchRestaurantsTags());

      restaurants = await restaurantController.fetchRestaurants();
      filteredData = restaurants;
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
        restaurants.where((restaurant) {
          if ((restaurant.name
                      .toString()
                      .toLowerCase()
                      .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
                      .split(" ")
                      .any((entryWord) => entryWord.startsWith(word)) ||
                  restaurant.name.toString().toLowerCase().split(" ").any((entryWord) => entryWord.startsWith(word))) &&
              !filteredData.contains(restaurant)) {
            if (selectedIndex == 0) {
              return true;
            } else if (selectedIndex != 0 && restaurant.tags.contains(tags[selectedIndex])) {
              return true;
            } else {
              return false;
            }
          }

          return false;
        }),
      );
    });

    if (query.trim().isEmpty) {
      if (selectedIndex == 0) {
        filteredData.addAll(restaurants);
      } else {
        filteredData.addAll(restaurants.where((restaurant) => restaurant.tags.contains(tags[selectedIndex])));
      }
    }

    setState(() {
      currentQuery = query;
    });
  }

  void setTag(int index) {
    setState(() {
      selectedIndex = index;
    });

    updateList(currentQuery);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, __) {
        setState(() => disableHero = true);
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
                  text: "Caută ",
                ),
                TextSpan(
                  text: "Localuri",
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
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
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
                          TagsListView(
                            tags: tags,
                            selectedIndex: selectedIndex,
                            onTagPressed: setTag,
                            hPadding: 24,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: filteredData.length,
                          (context, index) {
                            return RestaurantCard(
                              restaurant: filteredData[index],
                              heroTag: disableHero ? index.toString() : filteredData[index].id,
                            );
                          },
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

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final String heroTag;

  RestaurantCard({
    super.key,
    required this.restaurant,
    required this.heroTag,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/restaurant", arguments: restaurant),
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
                      CachedApiImage(
                        imageUrl: restaurant.images[restaurant.primaryImage - 1],
                        cacheHeight: Responsive.safeBlockVertical * 35,
                        height: double.infinity,
                        width: double.infinity,
                        blurhash: restaurant.primaryImageBlurhash,
                      ),
                      if (restaurant.tags.isNotEmpty)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: double.infinity,
                                color: Colors.black.withValues(alpha: 0.25),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        restaurant.tags.join(", "),
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
                      restaurant.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kBlackColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Consumer<LocationService>(
                      builder: (context, location, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/map-pin.svg",
                              width: 22,
                              colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              location.getDistance(restaurant.latitude, restaurant.longitude),
                              style: TextStyle(
                                fontSize: 14,
                                color: kForegroundColor.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        );
                      },
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
                          wishlist.toggleRestaurantWishState(restaurant.id);
                          likeAnimationKey.currentState!.animate();
                        },
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          wishlist.items['restaurants']!.contains(restaurant.id)
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: wishlist.items['restaurants']!.contains(restaurant.id)
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
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}
