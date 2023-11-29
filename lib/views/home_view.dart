import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/controllers/trending_controller.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/models/hotel_model.dart';
import 'package:visit_braila/models/restaurant_model.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/services/location_service.dart';
import 'package:visit_braila/utils/search_all.dart';
import 'package:visit_braila/utils/url_constants.dart';
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
  final TrendingController trendingController = TrendingController();

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();

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
                                  "assets/images/teatru.jpg",
                                  cacheHeight: Responsive.safeBlockVertical * 35,
                                  cacheWidth: Responsive.screenWidth,
                                ),
                                const Positioned.fill(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 14,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Brăila",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontFamily: bodyFont,
                                            height: 1.4,
                                          ),
                                        ),
                                        Text(
                                          "Un oraș istoric de pe malul Dunării",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontFamily: bodyFont,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
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
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: SizedBox(
                                height: Responsive.safeBlockHorizontal * 70,
                                width: double.infinity,
                                child: FutureBuilder<List<Object?>>(
                                  future: trendingController.fetchTrending(),
                                  builder: (context, trending) {
                                    if (trending.hasData) {
                                      if (trending.data!.isEmpty) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/trending-up.svg",
                                              width: 50,
                                              colorFilter: const ColorFilter.mode(kPrimaryColor, BlendMode.srcIn),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Nimic în tendințe astăzi",
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                                          switch (trending.data![index].runtimeType) {
                                            case Sight:
                                              Sight sight = trending.data![index] as Sight;

                                              return TrendingItemCard(
                                                collection: "sights",
                                                name: sight.name,
                                                image: sight.images[sight.primaryImage - 1],
                                                id: sight.id,
                                                latitude: sight.latitude,
                                                longitude: sight.longitude,
                                                pushTo: () => Navigator.pushNamed(context, "/sight", arguments: sight),
                                              );
                                            case Restaurant:
                                              Restaurant restaurant = trending.data![index] as Restaurant;

                                              return TrendingItemCard(
                                                collection: "restaurants",
                                                name: restaurant.name,
                                                image: restaurant.images[restaurant.primaryImage - 1],
                                                id: restaurant.id,
                                                latitude: restaurant.latitude,
                                                longitude: restaurant.longitude,
                                                pushTo: () =>
                                                    Navigator.pushNamed(context, "/restaurant", arguments: restaurant),
                                              );
                                            case Hotel:
                                              Hotel hotel = trending.data![index] as Hotel;

                                              return TrendingItemCard(
                                                collection: "hotels",
                                                name: hotel.name,
                                                image: hotel.images[hotel.primaryImage - 1],
                                                id: hotel.id,
                                                latitude: hotel.latitude,
                                                longitude: hotel.longitude,
                                                pushTo: () => Navigator.pushNamed(context, "/hotel", arguments: hotel),
                                              );
                                            case Event:
                                              Event event = trending.data![index] as Event;

                                              return TrendingEventCard(
                                                event: event,
                                              );
                                            default:
                                              return const SizedBox();
                                          }
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
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedAssetImage(
                                      "assets/images/plimbare_republicii.jpeg",
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
                                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pushNamed(context, "/alltours"),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 14),
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
                                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pushNamed(context, "/allsights"),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 14),
                                          ),
                                          child: const Text("Atracții"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          bottomLeft: Radius.circular(6),
                                        ),
                                        child: CachedAssetImage(
                                          "assets/images/peste.jpg",
                                          height: Responsive.safeBlockVertical * 30,
                                          width: (Responsive.screenWidth - 36) / 2,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  "Gusturi și arome",
                                                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pushNamed(context, "/allrestaurants"),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: Colors.black,
                                                  textStyle:
                                                      Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 14),
                                                ),
                                                child: const Text("Gastronomie"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 6),
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(6),
                                          bottomRight: Radius.circular(6),
                                        ),
                                        child: CachedAssetImage(
                                          "assets/images/alma.jpg",
                                          height: Responsive.safeBlockVertical * 30,
                                          width: (Responsive.screenWidth - 36) / 2,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  "Odihnă și confort",
                                                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pushNamed(context, "/allhotels"),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: Colors.black,
                                                  textStyle:
                                                      Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 14),
                                                ),
                                                child: const Text("Cazare"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 14,
                                right: 4,
                              ),
                              child: Text(
                                "Mobilitate și agrement",
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          bottomLeft: Radius.circular(6),
                                        ),
                                        child: CachedAssetImage(
                                          "assets/images/autobuze.jpg",
                                          height: Responsive.safeBlockVertical * 30,
                                          width: (Responsive.screenWidth - 36) / 2,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  "Transport public",
                                                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (Platform.isIOS) {
                                                    openBrowserURL(brTranporIOSUrl);
                                                  } else {
                                                    openBrowserURL(brTranportAndroidUrl);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: Colors.black,
                                                  textStyle:
                                                      Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 14),
                                                ),
                                                child: const Text("Ia bilet"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 6),
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(6),
                                          bottomRight: Radius.circular(6),
                                        ),
                                        child: CachedAssetImage(
                                          "assets/images/chira_chiralina.jpg",
                                          height: Responsive.safeBlockVertical * 30,
                                          width: (Responsive.screenWidth - 36) / 2,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  "Plimbări pe Dunăre",
                                                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              ElevatedButton(
                                                onPressed: () => openBrowserURL(brBoatUrl),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: Colors.black,
                                                  textStyle:
                                                      Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 14),
                                                ),
                                                child: const Text("Rezervă"),
                                              ),
                                            ],
                                          ),
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
                    ],
                  ),
                  AnimatedBuilder(
                    animation: _scrollController,
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
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

class TrendingItemCard extends StatelessWidget {
  final String collection;
  final String name;
  final String image;
  final String id;
  final double latitude;
  final double longitude;
  final void Function() pushTo;

  TrendingItemCard({
    super.key,
    required this.collection,
    required this.name,
    required this.image,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.pushTo,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pushTo,
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
                tag: id,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: const [shadowSm],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedApiImage(
                      imageUrl: image,
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
                          name,
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
                                switch (collection) {
                                  case "sights":
                                    wishlist.toggleSightWishState(id);
                                    break;
                                  case "restaurants":
                                    wishlist.toggleRestaurantWishState(id);
                                    break;
                                  case "hotels":
                                    wishlist.toggleHotelWishState(id);
                                    break;
                                }

                                likeAnimationKey.currentState!.animate();
                              },
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                wishlist.items[collection]!.contains(id)
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                size: 22,
                                color: wishlist.items[collection]!.contains(id)
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
                            colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            location.getDistance(latitude, longitude),
                            style: TextStyle(
                              fontSize: 12,
                              color: kForegroundColor.withOpacity(0.85),
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

class TrendingEventCard extends StatelessWidget {
  final Event event;

  const TrendingEventCard({
    super.key,
    required this.event,
  });

  String getDateInterval() {
    if (event.endDateTime == null) {
      return DateFormat.yMMMd('ro-RO').format(event.dateTime);
    }

    if (event.dateTime.month == event.endDateTime!.month && event.dateTime.year == event.endDateTime!.year) {
      return "${DateFormat.d('ro-RO').format(event.dateTime)} - ${DateFormat.d('ro-RO').format(event.endDateTime!)} ${DateFormat.MMM('ro-RO').format(event.endDateTime!)} ${DateFormat.y('ro-RO').format(event.endDateTime!)}";
    }

    return "${DateFormat.MMMd('ro-RO').format(event.dateTime)} -> ${DateFormat.MMMd('ro-RO').format(event.endDateTime!)}";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/event", arguments: event),
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
                tag: event.id,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: const [shadowSm],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedApiImage(
                      imageUrl: event.images[event.primaryImage - 1],
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
                          event.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kBlackColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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
                        Icons.calendar_month,
                        color: kDisabledIconColor,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        getDateInterval(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: kForegroundColor.withOpacity(0.85),
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
