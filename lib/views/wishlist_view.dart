import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/like_animation.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  final SightController sightController = SightController();
  List<Sight> sights = [];

  final TourController tourController = TourController();
  List<Tour> tours = [];

  bool isLoadingSights = true;
  bool isLoadingTours = true;

  void fetchSights() async {
    Wishlist wishlist = Provider.of<Wishlist>(context, listen: false);
    List<String> ids = wishlist.items['sights']!.toList();

    (await Future.wait(
      ids.map((id) => sightController.findSight(id)),
    ))
        .asMap()
        .forEach((index, sight) {
      if (sight == null) {
        wishlist.toggleSightWishState(ids.elementAt(index));
      } else {
        sights.add(sight);
      }
    });

    if (mounted) {
      setState(() => isLoadingSights = false);
    }
  }

  void fetchTours() async {
    Wishlist wishlist = Provider.of<Wishlist>(context, listen: false);
    List<String> ids = wishlist.items['tours']!.toList();

    (await Future.wait(
      ids.map((id) => tourController.findTour(id)),
    ))
        .asMap()
        .forEach((index, tour) {
      if (tour == null) {
        wishlist.toggleTourWishState(ids.elementAt(index));
      } else {
        tours.add(tour);
      }
    });

    if (mounted) {
      setState(() => isLoadingTours = false);
    }
  }

  @override
  void initState() {
    super.initState();

    fetchSights();
    fetchTours();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        isLoadingSights
            ? const LoadingSpinner()
            : sights.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/sad-outline.svg",
                        width: 50,
                        color: kDisabledIconColor,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Nu ai niciun obiectiv favorit!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: kDimmedForegroundColor,
                            ),
                      )
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 15,
                    ),
                    itemCount: sights.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: 20,
                      );
                    },
                    itemBuilder: (context, index) {
                      return SightCard(
                        sight: sights[index],
                      );
                    },
                  ),
        isLoadingTours
            ? const LoadingSpinner()
            : tours.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/sad-outline.svg",
                        width: 50,
                        color: kDisabledIconColor,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Nu ai niciun tur favorit!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: kDimmedForegroundColor,
                            ),
                      )
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 15,
                    ),
                    itemCount: tours.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: 20,
                      );
                    },
                    itemBuilder: (context, index) {
                      return TourCard(
                        tour: tours[index],
                      );
                    },
                  ),
      ],
    );
  }
}

class SightCard extends StatelessWidget {
  final Sight sight;

  SightCard({
    super.key,
    required this.sight,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/sight", arguments: sight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Hero(
            tag: sight.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedApiImage(
                imageUrl: sight.images[sight.primaryImage - 1],
                width: 110,
                height: 75,
                cacheWidth: 110,
                cacheHeight: 75,
                blur: true,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
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
          Padding(
            padding: const EdgeInsets.only(left: 8),
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
                      wishlist.items['sights']!.contains(sight.id) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      size: 22,
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
    );
  }
}

class TourCard extends StatelessWidget {
  final Tour tour;

  TourCard({
    super.key,
    required this.tour,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/tour", arguments: tour),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Hero(
            tag: tour.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedApiImage(
                imageUrl: tour.images[tour.primaryImage - 1],
                width: 110,
                height: 75,
                cacheWidth: 110,
                cacheHeight: 75,
                blur: true,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              tour.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kBlackColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: LikeAnimation(
              key: likeAnimationKey,
              child: Consumer<Wishlist>(
                builder: (context, wishlist, _) {
                  return IconButton(
                    splashRadius: 1,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      wishlist.toggleTourWishState(tour.id);
                      likeAnimationKey.currentState!.animate();
                    },
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      wishlist.items['tours']!.contains(tour.id) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      size: 22,
                      color: wishlist.items['tours']!.contains(tour.id)
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
    );
  }
}
