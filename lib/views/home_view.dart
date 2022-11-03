import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/search_all.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/like_animation.dart';
import 'package:visit_braila/widgets/skeleton.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/responsive.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final ScrollController _scrollController = ScrollController();
  final double appBarBreakpoint = 270;

  final SightController sightController = SightController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              height: Responsive.safePaddingTop,
              color: Colors.black,
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset("assets/images/braila_night.jpg"),
                                const Positioned(
                                  bottom: 0,
                                  child: FractionalTranslation(
                                    translation: Offset(0, 0.5),
                                    child: SearchBar(),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 24),
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Brăila",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " - un oraș istoric de pe malul Dunării",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Merriweather",
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 38,
                            left: 14,
                            right: 14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 14,
                                  right: 4,
                                ),
                                child: Text(
                                  "Inspirație pentru următoarea ta călătorie",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: SizedBox(
                                  height: Responsive.safeBlockHorizontal * 70,
                                  child: FutureBuilder<List<Sight>>(
                                    future: sightController.fetchTrending(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return ListView.separated(
                                          itemCount: snapshot.data!.length,
                                          clipBehavior: Clip.none,
                                          scrollDirection: Axis.horizontal,
                                          separatorBuilder: (context, index) {
                                            return const SizedBox(width: 10);
                                          },
                                          itemBuilder: (context, index) {
                                            return TrendingSightCard(
                                              sight: snapshot.data![index],
                                            );
                                          },
                                        );
                                      } else if (snapshot.error is SocketException) {
                                        showErrorDialog(context, false);
                                      } else if (snapshot.error is HttpException) {
                                        showErrorDialog(context, true);
                                      }

                                      return ListView.separated(
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: 4,
                                        scrollDirection: Axis.horizontal,
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(width: 10);
                                        },
                                        itemBuilder: (context, index) {
                                          return const SkeletonCard();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 14,
                                  right: 4,
                                ),
                                child: Text(
                                  "Descoperă locuri și oameni",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        "assets/images/republicii.jpg",
                                        height: Responsive.safeBlockVertical * 30,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Fă o plimbare",
                                            style: Theme.of(context).textTheme.headline3!.copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pushNamed(context, "/alltours"),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 28,
                                                vertical: 14,
                                              ),
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                              textStyle: Theme.of(context).textTheme.button,
                                            ),
                                            child: const Text("Tururi"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        "assets/images/biserica_greceasca.jpg",
                                        height: Responsive.safeBlockVertical * 30,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Explorează noi culturi",
                                            style: Theme.of(context).textTheme.headline3!.copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 28,
                                                vertical: 14,
                                              ),
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                              textStyle: Theme.of(context).textTheme.button,
                                            ),
                                            child: const Text("Atracții"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _scrollController,
                    builder: ((context, child) {
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _scrollController.offset >= appBarBreakpoint ? 1 : 0,
                        child: Container(
                          color: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SearchBar(),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSearch(context: context, delegate: SearchAll()),
      child: Container(
        width: Responsive.screenWidth / 1.25,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white,
          boxShadow: const [shadowSm],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.search,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "Unde vrei să mergi?",
              style: Theme.of(context).textTheme.headline4!.copyWith(
                    color: kDimmedForegroundColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Skeleton(
            width: Responsive.safeBlockHorizontal * 60,
          ),
        ),
        const SizedBox(height: 10),
        Skeleton(
          width: Responsive.safeBlockHorizontal * 45,
        ),
        const SizedBox(height: 10),
        Skeleton(
          width: Responsive.safeBlockHorizontal * 30,
        ),
      ],
    );
  }
}

class TrendingSightCard extends StatelessWidget {
  final Sight sight;

  TrendingSightCard({
    super.key,
    required this.sight,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/sight", arguments: sight),
      child: Container(
        width: Responsive.safeBlockHorizontal * 60,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [shadowSm],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: sight.id,
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: [shadowSm],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      sight.images[sight.primaryImage - 1],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          sight.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kBlackColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      LikeAnimation(
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
                                size: 22,
                                color: wishlist.items['sights']!.contains(sight.id)
                                    ? Theme.of(context).colorScheme.secondary
                                    : kDisabledIconColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        FeatherIcons.mapPin,
                        size: 18,
                        color: kDisabledIconColor,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        "N/A",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
