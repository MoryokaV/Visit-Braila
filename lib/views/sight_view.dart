import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/html_description.dart';
import 'package:visit_braila/widgets/like_animation.dart';

class SightView extends StatelessWidget {
  final Sight sight;
  final Animation<double> routeAnimation;

  SightView({
    super.key,
    required this.sight,
    required this.routeAnimation,
  });

  final SightController sightController = SightController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(id: sight.id),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
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
                background: Hero(
                  tag: sight.id,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        sight.images[sight.primaryImage - 1],
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 30,
                          width: Responsive.screenWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: fadeEffect,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        color: kBlackColor,
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
                        color: kBlackColor,
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
                  child: AnimatedBuilder(
                    animation: routeAnimation,
                    builder: (context, _) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: routeAnimation,
                          curve: const Interval(0.6, 1),
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
                            if (sight.tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  sight.tags.join(", "),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 18,
                            ),
                            HtmlDescription(
                              data: sight.description,
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            SizedBox(
                              height: Responsive.safeBlockHorizontal * 35,
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
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
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
