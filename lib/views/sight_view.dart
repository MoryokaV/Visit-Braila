import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/services/dynamic_links_service.dart';
import 'package:visit_braila/services/location_service.dart';
import 'package:visit_braila/utils/maps.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/actions_bar.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/html_description.dart';
import 'dart:io' show Platform;

class SightView extends StatelessWidget {
  final Sight sight;
  final Animation<double> routeAnimation;

  const SightView({
    super.key,
    required this.sight,
    required this.routeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ActionsBar(
        id: sight.id,
        collection: "sights",
        text: "Vizitează acum",
        link: sight.externalLink,
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              stretch: true,
              automaticallyImplyLeading: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              expandedHeight: Responsive.safeBlockVertical * 38,
              flexibleSpace: FlexibleSpaceBar(
                background: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    "/gallery",
                    arguments: {
                      "startIndex": sight.primaryImage - 1,
                      "images": sight.images,
                      "title": sight.name,
                      "id": sight.id,
                      "collection": "sights",
                      "type": "sight",
                      "primaryImage": sight.primaryImage,
                      "externalLink": sight.externalLink,
                    },
                  ),
                  child: Hero(
                    tag: sight.id,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedApiImage(
                          imageUrl: sight.images[sight.primaryImage - 1],
                          cacheWidth: Responsive.screenWidth,
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
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                    child: IconButton(
                      color: kForegroundColor,
                      padding: EdgeInsets.zero,
                      icon: FractionalTranslation(
                        translation: Platform.isIOS ? const Offset(0.2, 0) : const Offset(0, 0),
                        child: Icon(
                          Icons.adaptive.arrow_back,
                          size: 18,
                          color: kBlackColor,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        child: IconButton(
                          color: kForegroundColor,
                          icon: const Icon(
                            CupertinoIcons.location,
                            size: 18,
                            color: kBlackColor,
                          ),
                          onPressed: () => openMap(sight.latitude, sight.longitude, sight.name, context),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      FractionalTranslation(
                        translation: Platform.isIOS ? const Offset(0, 0) : const Offset(0, 0),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withValues(alpha: 0.8),
                          child: IconButton(
                            color: kForegroundColor,
                            icon: Icon(
                              Icons.adaptive.share,
                              size: 18,
                              color: kBlackColor,
                            ),
                            onPressed: () async {
                              final link = await DynamicLinksService.generateDynamicLink(
                                id: sight.id,
                                image: sight.images[sight.primaryImage - 1],
                                name: sight.name,
                                collection: "sight",
                                alternativeUrl: sight.externalLink,
                              );

                              Share.share(link.toString());
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              sliver: SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: routeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sight.name,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(
                        height: 8,
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
                                colorFilter: const ColorFilter.mode(kPrimaryColor, BlendMode.srcIn),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                "${location.getDistance(sight.latitude, sight.longitude)} depărtare",
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
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
                        shrink: true,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        height: Responsive.safeBlockHorizontal * 35,
                        child: ListView.separated(
                          itemCount: sight.images.length > 4 ? 5 : sight.images.length,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 10);
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                "/gallery",
                                arguments: {
                                  "startIndex": index,
                                  "images": sight.images,
                                  "title": sight.name,
                                  "id": sight.id,
                                  "collection": "sights",
                                  "type": "sight",
                                  "primaryImage": sight.primaryImage,
                                  "externalLink": sight.externalLink,
                                },
                              ),
                              child: index != 4
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedApiImage(
                                        imageUrl: sight.images[index],
                                        width: Responsive.safeBlockVertical * 25,
                                        cacheWidth: Responsive.safeBlockVertical * 25,
                                      ),
                                    )
                                  : Container(
                                      width: Responsive.safeBlockVertical * 25,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: lightGrey,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "+${sight.images.length - 4}",
                                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 24),
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: routeAnimation,
                        curve: const Interval(0.6, 1),
                      ),
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
