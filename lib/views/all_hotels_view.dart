import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:visit_braila/controllers/hotel_controller.dart';
import 'package:visit_braila/models/hotel_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/search_all.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';
import 'package:visit_braila/widgets/search_list_field.dart';
import 'package:visit_braila/widgets/tags_listview.dart';

class AllHotelsView extends StatefulWidget {
  const AllHotelsView({super.key});

  @override
  State<AllHotelsView> createState() => _AllHotelsViewState();
}

class _AllHotelsViewState extends State<AllHotelsView> {
  final HotelController hotelController = HotelController();
  List<Hotel> hotels = [];
  List<Hotel> filteredData = [];

  List<String> tags = [];
  int selectedIndex = 0;

  bool isLoading = true;
  bool disableHero = false;

  String currentQuery = "";

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    try {
      tags.add("Toate");
      tags.addAll(await hotelController.fetchHotelsTags());

      hotels = await hotelController.fetchHotels();
      filteredData = hotels;
    } on HttpException {
      if (mounted) {
        showErrorDialog(context);
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void updateList(String query) {
    filteredData = [];

    query.trim().toLowerCase().split(" ").forEach((word) {
      if (word == "") {
        return;
      }

      if (prepositions.contains(word)) {
        return;
      }

      filteredData.addAll(
        hotels.where((hotel) {
          if ((hotel.name
                      .toString()
                      .toLowerCase()
                      .replaceAllMapped(RegExp('[ĂăÂâÎîȘșȚț]'), (m) => diacriticsMapping[m.group(0)] ?? '')
                      .split(" ")
                      .any((entryWord) => entryWord.startsWith(word)) ||
                  hotel.name.toString().toLowerCase().split(" ").any((entryWord) => entryWord.startsWith(word))) &&
              !filteredData.contains(hotel)) {
            if (selectedIndex == 0) {
              return true;
            } else if (selectedIndex != 0 && hotel.tags.contains(tags[selectedIndex])) {
              return true;
            } else {
              return false;
            }
          }

          return false;
        }),
      );
    });

    if (query.trim().isEmpty) {
      if (selectedIndex == 0) {
        filteredData.addAll(hotels);
      } else {
        filteredData.addAll(hotels.where((hotel) => hotel.tags.contains(tags[selectedIndex])));
      }
    }

    setState(() {
      currentQuery = query;
    });
  }

  void setTag(int index) {
    setState(() {
      selectedIndex = index;
    });

    updateList(currentQuery);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() => disableHero = true);

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kBackgroundColor,
          elevation: 0,
          titleSpacing: 0,
          title: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Caută ",
                ),
                TextSpan(
                  text: "Cazare",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              setState(() => disableHero = true);

              Navigator.pop(context);
            },
            icon: Icon(
              Icons.adaptive.arrow_back,
              color: kForegroundColor,
            ),
          ),
        ),
        body: SafeArea(
          child: isLoading
              ? const LoadingSpinner()
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 14,
                          right: 14,
                          top: 10,
                        ),
                        child: Column(children: [
                          SearchListField(
                            onChanged: updateList,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TagsListView(
                            tags: tags,
                            selectedIndex: selectedIndex,
                            onTagPressed: setTag,
                            hPadding: 0,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ]),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 20),
                      sliver: SliverMasonryGrid.count(
                        childCount: filteredData.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemBuilder: (context, index) {
                          return HotelCard(
                            hotel: filteredData[index],
                            heroTag: disableHero ? index.toString() : filteredData[index].id,
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final String heroTag;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/hotel", arguments: hotel),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                CachedApiImage(
                  imageUrl: hotel.images[hotel.primaryImage - 1],
                  cacheWidth: Responsive.screenWidth / 2,
                ),
                Positioned.fill(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                    ),
                    child: Text(
                      hotel.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
