import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/like_animation.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class SightView extends StatelessWidget {
  final String id;

  SightView({
    super.key,
    required this.id,
  });

  final SightController sightController = SightController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(
        id: id,
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<Sight>(
          future: sightController.findSight(id),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              final Sight sight = snapshot.data!;
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    stretch: true,
                    automaticallyImplyLeading: false,
                    pinned: true,
                    floating: false,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    expandedHeight: Responsive.safeBlockVertical * 38,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            sight.images[sight.primaryImage - 1],
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: fadeEffect,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            color: kForegroundColor,
                            icon: Icon(
                              Icons.adaptive.arrow_back,
                              size: 18,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            color: kForegroundColor,
                            icon: Icon(
                              Icons.adaptive.share,
                              size: 18,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sight.name,
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(
                                  FeatherIcons.mapPin,
                                  size: 22,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  //TODO: dynamic distance with GoogleMaps Api
                                  "N/A",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              sight.description,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            SizedBox(
                              height: Responsive.safeBlockHorizontal * 40,
                              child: ListView.separated(
                                itemCount: sight.images.length,
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(width: 10);
                                },
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        sight.images[index],
                                        fit: BoxFit.cover,
                                        width:
                                            Responsive.safeBlockVertical * 25,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              //TODO: NOT FOUND SCREEN
              return const Text("Error");
            }

            return const LoadingSpinner();
          }),
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final String id;

  BottomBar({
    super.key,
    required this.id,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [topShadow],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: Responsive.screenWidth / 8,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    textStyle: Theme.of(context).textTheme.button,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                  child: const Text("Vizitează acum"),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              LikeAnimation(
                key: likeAnimationKey,
                child: Consumer<Wishlist>(builder: (context, favourites, _) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [globalShadow],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        favourites.toggleSightWishState(id);
                        likeAnimationKey.currentState!.animate();
                      },
                      icon: Icon(
                        favourites.items['sights']!.contains(id)
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: favourites.items['sights']!.contains(id)
                            ? Theme.of(context).colorScheme.secondary
                            : kForegroundColor,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
