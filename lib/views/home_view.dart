import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/services/location_service.dart';
import 'package:visit_braila/utils/search_all.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/like_animation.dart';
import 'package:visit_braila/widgets/skeleton.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/responsive.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

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
                  ListView(
                    primary: false,
                    padding: EdgeInsets.zero,
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      SizedBox(
                        height: Responsive.safeBlockVertical * 35 + 20,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                CachedAssetImage(
                                  "assets/images/braila_night.jpg",
                                  cacheHeight: Responsive.safeBlockVertical * 35,
                                  cacheWidth: Responsive.screenWidth,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 18, top: 12),
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
                                        fontFamily: bodyFont,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Positioned(
                              bottom: 0,
                              child: SearchBar(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 22,
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
                                width: double.infinity,
                                child: FutureBuilder<List<Sight>>(
                                  future: sightController.fetchTrending(),
                                  builder: (context, trending) {
                                    if (trending.hasData) {
                                      if (trending.data!.isEmpty) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/trending-up.svg",
                                              width: 50,
                                              color: kPrimaryColor,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Nimic în tendințe astăzi",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                                    color: kDimmedForegroundColor,
                                                  ),
                                            ),
                                          ],
                                        );
                                      }

                                      return ListView.separated(
                                        itemCount: trending.data!.length,
                                        clipBehavior: Clip.none,
                                        scrollDirection: Axis.horizontal,
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(width: 15);
                                        },
                                        itemBuilder: (context, index) {
                                          return TrendingSightCard(
                                            sight: trending.data![index],
                                          );
                                        },
                                      );
                                    } else if (trending.hasError && trending.error is HttpException) {
                                      showErrorDialog(context);
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
                                    child: CachedAssetImage(
                                      "assets/images/republicii.jpg",
                                      width: double.infinity,
                                      height: Responsive.safeBlockVertical * 30,
                                      cacheHeight: Responsive.safeBlockVertical * 30,
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
                                    child: CachedAssetImage(
                                      "assets/images/biserica_greceasca.jpg",
                                      height: Responsive.safeBlockVertical * 30,
                                      width: double.infinity,
                                      cacheHeight: Responsive.safeBlockVertical * 30,
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
                                          onPressed: () => Navigator.pushNamed(context, "/allsights"),
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
                  AnimatedBuilder(
                    animation: _scrollController,
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
                    builder: (context, child) {
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _scrollController.offset >= appBarBreakpoint ? 1 : 0,
                        child: child,
                      );
                    },
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
        padding: const EdgeInsets.all(10),
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
            Flexible(
              child: Text(
                "Unde vrei să mergi?",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: kDimmedForegroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
                  decoration: BoxDecoration(
                    boxShadow: const [shadowSm],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedApiImage(
                      imageUrl: sight.images[sight.primaryImage - 1],
                      width: double.infinity,
                      cacheWidth: Responsive.safeBlockHorizontal * 60,
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
                  Consumer<LocationService>(
                    builder: (context, location, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/map-pin.svg",
                            width: 18,
                            color: kDisabledIconColor,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            location.getDistance(sight.latitude, sight.longitude),
                            style: TextStyle(
                              fontSize: 12,
                              color: kForegroundColor.withOpacity(0.85)
                            ),
                          ),
                        ],
                      );
                    },
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
