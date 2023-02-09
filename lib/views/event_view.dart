import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/services/dynamic_links_service.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/html_description.dart';

class EventView extends StatelessWidget {
  final Event event;
  final Animation<double> routeAnimation;

  const EventView({
    super.key,
    required this.event,
    required this.routeAnimation,
  });

  String getDateInterval() {
    if (event.endDateTime == null) {
      return DateFormat.yMMMMEEEEd('ro-RO').format(event.dateTime);
    }

    if (event.dateTime.month == event.endDateTime!.month && event.dateTime.year == event.endDateTime!.year) {
      return "${DateFormat.EEEE('ro-RO').format(event.dateTime)} ${DateFormat.d('ro-RO').format(event.dateTime)} -> ${DateFormat.EEEE('ro-RO').format(event.endDateTime!)} ${DateFormat.d('ro-RO').format(event.endDateTime!)}, ${DateFormat.yMMMM('ro-RO').format(event.endDateTime!)}";
    }

    return "${DateFormat.yMMMMEEEEd('ro-RO').format(event.dateTime)} -> ${DateFormat.yMMMMEEEEd('ro-RO').format(event.endDateTime!)}";
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();

    return Scaffold(
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
                  tag: event.id,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedApiImage(
                        imageUrl: event.images[event.primaryImage - 1],
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.8),
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
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          color: kForegroundColor,
                          icon: Icon(
                            Icons.adaptive.share,
                            size: 18,
                            color: kBlackColor,
                          ),
                          onPressed: () async {
                            final link = await DynamicLinksService.generateDynamicLink(
                              id: event.id,
                              image: event.images[event.primaryImage - 1],
                              name: event.name,
                              collection: "event",
                              alternativeUrl: event.externalLink,
                            );

                            Share.share(link.toString());
                          },
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
                        event.name,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: kDisabledIconColor,
                            size: 22,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Flexible(
                            child: Text(
                              getDateInterval(),
                              style: const TextStyle(
                                color: kDateTimeForegroundColor,
                                fontFamily: labelFont,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/clock.svg",
                            color: kDisabledIconColor,
                            width: 22,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            DateFormat.Hm('ro-RO').format(event.dateTime),
                            style: const TextStyle(
                              color: kDateTimeForegroundColor,
                              fontFamily: labelFont,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      HtmlDescription(
                        data: event.description,
                        shrink: true,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        height: Responsive.safeBlockHorizontal * 35,
                        child: ListView.separated(
                          itemCount: event.images.length > 4 ? 5 : event.images.length,
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
                                  "event": event,
                                },
                              ),
                              child: index != 4
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedApiImage(
                                        imageUrl: event.images[index],
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
                                          "+${event.images.length - 4}",
                                          style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24),
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
