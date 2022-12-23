import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:visit_braila/controllers/event_controller.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/skeleton.dart';

class AllEventsView extends StatelessWidget {
  AllEventsView({super.key});

  final EventController eventController = EventController();

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();

    return SafeArea(
      child: FutureBuilder<List<Event>>(
        future: eventController.fetchEvents(),
        builder: (context, events) {
          if (events.hasData) {
            if (events.data!.isEmpty) {
              return SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/calendar4-event.svg",
                      width: 50,
                      color: kDisabledIconColor,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Niciun eveniment activ",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: kDimmedForegroundColor,
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              itemCount: events.data!.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: events.data![index],
                );
              },
              separatorBuilder: (_, __) {
                return const SizedBox(
                  height: 16,
                );
              },
            );
          } else if (events.hasError && events.error is HttpException) {
            showErrorDialog(context);
          }

          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            separatorBuilder: (context, index) {
              return const SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              return Skeleton(
                width: double.infinity,
                height: Responsive.safeBlockVertical * 25,
              );
            },
          );
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
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
      onTap: () => Navigator.pushNamed(context, '/event', arguments: event),
      child: Container(
        height: Responsive.safeBlockVertical * 25,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [tinyShadow],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Flexible(
              flex: 4,
              child: Hero(
                tag: event.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    fadeOutDuration: const Duration(milliseconds: 700),
                    fadeInDuration: const Duration(milliseconds: 300),
                    imageUrl: event.images[event.primaryImage - 1],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          event.name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: const TextStyle(
                            color: kBlackColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(thickness: 0.75),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          style: const TextStyle(
                            color: kDateTimeForegroundColor,
                            fontFamily: labelFont,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/clock.svg",
                          color: kDisabledIconColor,
                          width: 20,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          DateFormat.Hm('ro-RO').format(event.dateTime),
                          style: const TextStyle(
                            color: kDateTimeForegroundColor,
                            fontFamily: labelFont,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
