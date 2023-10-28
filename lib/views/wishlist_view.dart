import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/hotel_controller.dart';
import 'package:visit_braila/controllers/restaurant_controller.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/controllers/tour_controller.dart';
import 'package:visit_braila/models/hotel_model.dart';
import 'package:visit_braila/models/restaurant_model.dart';
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

  final HotelController hotelController = HotelController();
  List<Hotel> hotels = [];

  final RestaurantController restaurantController = RestaurantController();
  List<Restaurant> restaurants = [];

  bool isLoadingSights = true;
  bool isLoadingTours = true;
  bool isLoadingHotels = true;
  bool isLoadingRestaurants = true;

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

  void fetchHotels() async {
    Wishlist wishlist = Provider.of<Wishlist>(context, listen: false);
    List<String> ids = wishlist.items['hotels']!.toList();

    (await Future.wait(
      ids.map((id) => hotelController.findHotel(id)),
    ))
        .asMap()
        .forEach((index, hotel) {
      if (hotel == null) {
        wishlist.toggleHotelWishState(ids.elementAt(index));
      } else {
        hotels.add(hotel);
      }
    });

    if (mounted) {
      setState(() => isLoadingHotels = false);
    }
  }

  void fetchRestaurants() async {
    Wishlist wishlist = Provider.of<Wishlist>(context, listen: false);
    List<String> ids = wishlist.items['restaurants']!.toList();

    (await Future.wait(
      ids.map((id) => restaurantController.findRestaurant(id)),
    ))
        .asMap()
        .forEach((index, restaurant) {
      if (restaurant == null) {
        wishlist.toggleRestaurantWishState(ids.elementAt(index));
      } else {
        restaurants.add(restaurant);
      }
    });

    if (mounted) {
      setState(() => isLoadingRestaurants = false);
    }
  }

  @override
  void initState() {
    super.initState();

    fetchSights();
    fetchTours();
    fetchHotels();
    fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        isLoadingSights
            ? const LoadingSpinner()
            : sights.isEmpty
                ? const EmptyWishlistCollectionWidget(
                    text: "Nu ai niciun obiectiv favorit!",
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 15,
                    ),
                    itemCount: sights.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 20);
                    },
                    itemBuilder: (context, index) {
                      Sight sight = sights[index];

                      return WishlistItemCard(
                        id: sight.id,
                        name: sight.name,
                        image: sight.images[sight.primaryImage - 1],
                        collection: "sights",
                        pushTo: () => Navigator.pushNamed(context, "/sight", arguments: sight),
                      );
                    },
                  ),
        isLoadingTours
            ? const LoadingSpinner()
            : tours.isEmpty
                ? const EmptyWishlistCollectionWidget(
                    text: "Nu ai niciun tur favorit!",
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 15,
                    ),
                    itemCount: tours.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 20);
                    },
                    itemBuilder: (context, index) {
                      Tour tour = tours[index];

                      return WishlistItemCard(
                        id: tour.id,
                        name: tour.name,
                        image: tour.images[tour.primaryImage - 1],
                        collection: "tours",
                        pushTo: () => Navigator.pushNamed(context, "/tour", arguments: tour),
                      );
                    },
                  ),
        isLoadingRestaurants
            ? const LoadingSpinner()
            : restaurants.isEmpty
                ? const EmptyWishlistCollectionWidget(
                    text: "Nu ai nicio unitate gastronomică favorită!",
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 15,
                    ),
                    itemCount: restaurants.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 20);
                    },
                    itemBuilder: (context, index) {
                      Restaurant restaurant = restaurants[index];

                      return WishlistItemCard(
                        id: restaurant.id,
                        name: restaurant.name,
                        image: restaurant.images[restaurant.primaryImage - 1],
                        collection: "restaurants",
                        pushTo: () => Navigator.pushNamed(context, "/restaurant", arguments: restaurant),
                      );
                    },
                  ),
        isLoadingHotels
            ? const LoadingSpinner()
            : hotels.isEmpty
                ? const EmptyWishlistCollectionWidget(
                    text: "Nu ai nicio unitate de cazare favorită!",
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 15,
                    ),
                    itemCount: hotels.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 20);
                    },
                    itemBuilder: (context, index) {
                      Hotel hotel = hotels[index];

                      return WishlistItemCard(
                        id: hotel.id,
                        name: hotel.name,
                        image: hotel.images[hotel.primaryImage - 1],
                        collection: "hotels",
                        pushTo: () => Navigator.pushNamed(context, "/hotel", arguments: hotel),
                      );
                    },
                  ),
      ],
    );
  }
}

class EmptyWishlistCollectionWidget extends StatelessWidget {
  final String text;

  const EmptyWishlistCollectionWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/sad-outline.svg",
            width: 50,
            colorFilter: ColorFilter.mode(kDisabledIconColor, BlendMode.srcIn),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: kDimmedForegroundColor,
                ),
          )
        ],
      ),
    );
  }
}

class WishlistItemCard extends StatelessWidget {
  final String id;
  final String name;
  final String image;
  final String collection;
  final void Function() pushTo;

  WishlistItemCard({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.collection,
    required this.pushTo,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pushTo,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Hero(
            tag: id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedApiImage(
                imageUrl: image,
                width: 110,
                height: 75,
                cacheWidth: 110,
                cacheHeight: 75,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
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
                      switch (collection) {
                        case "sights":
                          wishlist.toggleSightWishState(id);
                          break;
                        case "tours":
                          wishlist.toggleTourWishState(id);
                          break;
                        case "hotels":
                          wishlist.toggleHotelWishState(id);
                          break;
                        case "restaurants":
                          wishlist.toggleRestaurantWishState(id);
                          break;
                      }

                      likeAnimationKey.currentState!.animate();
                    },
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      wishlist.items[collection]!.contains(id) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      size: 22,
                      color: wishlist.items[collection]!.contains(id)
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
