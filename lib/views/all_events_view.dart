import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:visit_braila/controllers/event_controller.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/skeleton.dart';

class AllEventsView extends StatefulWidget {
  const AllEventsView({super.key});

  @override
  State<AllEventsView> createState() => _AllEventsViewState();
}

class _AllEventsViewState extends State<AllEventsView> {
  final EventController eventController = EventController();

  String? currentRange;
  List<int> ranges = [];
  bool firstListBuild = true;

  String? getSeparatorText(DateTime date) {
    if (date.year > DateTime.now().year) {
      return "-- ${date.year.toString()}";
    } else if (date.day.compareTo(DateTime.now().day) == 0) {
      return "-- Astăzi";
    } else if (date.month == DateTime.now().month && date.day - DateTime.now().day < 0) {
      return null;
    } else if (date.month == DateTime.now().month && date.day - DateTime.now().day <= 7 - DateTime.now().weekday) {
      return "-- Săptămâna aceasta";
    } else if (date.year == DateTime.now().year) {
      String month = DateFormat.MMMM('ro-RO').format(date);
      return "-- ${month[0].toUpperCase()}${month.substring(1)}";
    }

    return null;
  }

  void setRanges(List<Event> events) {
    for (int i = 0; i < events.length; i++) {
      if (getSeparatorText(events[i].dateTime) != currentRange) {
        currentRange = getSeparatorText(events[i].dateTime);
        ranges.add(i);
      }
    }

    firstListBuild = false;
  }

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
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                if (firstListBuild) {
                  setRanges(events.data!);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ranges.contains(index))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          getSeparatorText(events.data![index].dateTime)!,
                          style: const TextStyle(
                            fontFamily: labelFont,
                            color: kDateTimeForegroundColor,
                          ),
                        ),
                      ),
                    EventCard(
                      event: events.data![index],
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) {
                return const SizedBox(height: 16);
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
                  child: CachedApiImage(
                    imageUrl: event.images[event.primaryImage - 1],
                    width: double.infinity,
                    height: double.infinity,
                    cacheHeight: Responsive.safeBlockVertical * 25,
                    blurhash: event.primaryImageBlurhash,
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
