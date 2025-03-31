import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visit_braila/models/hotel_model.dart';
import 'package:flutter/material.dart';
import 'package:visit_braila/services/dynamic_links_service.dart';
import 'package:visit_braila/utils/maps.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/actions_bar.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/html_description.dart';

class HotelView extends StatelessWidget {
  final Hotel hotel;
  final Animation<double> routeAnimation;

  const HotelView({
    super.key,
    required this.hotel,
    required this.routeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ActionsBar(
        id: hotel.id,
        collection: "hotels",
        text: "Rezervă",
        link: hotel.externalLink,
        phone: hotel.phone,
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
                background: Hero(
                  tag: hotel.id,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedApiImage(
                        imageUrl: hotel.images[hotel.primaryImage - 1],
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
                      )
                    ],
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
                          onPressed: () => openMap(hotel.latitude, hotel.longitude, hotel.name, context),
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
                                id: hotel.id,
                                image: hotel.images[hotel.primaryImage - 1],
                                name: hotel.name,
                                collection: "hotel",
                                alternativeUrl: hotel.externalLink,
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
                        hotel.name,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            for (int i = 1; i <= hotel.stars; i++)
                              Icon(
                                Platform.isIOS ? CupertinoIcons.star_fill : Icons.star,
                                color: kHotelStarColor,
                                size: 16,
                              ),
                            if (hotel.tags.isNotEmpty)
                              const SizedBox(
                                width: 8,
                              ),
                            if (hotel.tags.isNotEmpty)
                              Text(
                                hotel.tags.join(", "),
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      HtmlDescription(
                        data: hotel.description,
                        shrink: true,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        height: Responsive.safeBlockHorizontal * 35,
                        child: ListView.separated(
                          itemCount: hotel.images.length > 4 ? 5 : hotel.images.length,
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
                                  "images": hotel.images,
                                  "title": hotel.name,
                                  "id": hotel.id,
                                  "collection": "hotels",
                                  "type": "hotel",
                                  "primaryImage": hotel.primaryImage,
                                  "externalLink": hotel.externalLink,
                                },
                              ),
                              child: index != 4
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedApiImage(
                                        imageUrl: hotel.images[index],
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
                                          "+${hotel.images.length - 4}",
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
            )
          ],
        ),
      ),
    );
  }
}
