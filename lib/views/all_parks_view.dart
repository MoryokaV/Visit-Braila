import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/controllers/park_controller.dart';
import 'package:visit_braila/models/park_model.dart';
import 'package:visit_braila/services/location_service.dart';
import 'package:visit_braila/utils/maps.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/error_dialog.dart';
import 'package:visit_braila/widgets/loading_spinner.dart';

class AllParksView extends StatefulWidget {
  const AllParksView({super.key});

  @override
  State<AllParksView> createState() => _AllParksViewState();
}

class _AllParksViewState extends State<AllParksView> {
  bool isLoading = true;
  final ParkController parkController = ParkController();
  List<Park> parks = [];
  List<Park> parksRelaxare = [];
  List<Park> parksJoaca = [];
  List<Park> parksFitness = [];

  void fetchData() async {
    try {
      parks = await parkController.fetchParks();
      for (var park in parks) {
        if (park.type == ParkType.relaxare) {
          parksRelaxare.add(park);
        } else if (park.type == ParkType.joaca) {
          parksJoaca.add(park);
        } else {
          parksFitness.add(park);
        }
      }
    } on HttpException {
      if (mounted) {
        showErrorDialog(context);
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kBackgroundColor,
          elevation: 2,
          titleSpacing: 0,
          title: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Parcuri",
                )
              ],
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
            ),
          ),
          bottom: const TabBar(
            labelColor: kPrimaryColor,
            indicatorColor: kPrimaryColor,
            indicatorWeight: 2.5,
            tabs: [
              Tab(
                text: "Relaxare",
              ),
              Tab(
                text: "Joacă",
              ),
              Tab(
                text: "Fitness",
              ),
            ],
          ),
          leading: IconButton(
            onPressed: () {
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
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TabBarView(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: parksRelaxare.length,
                        itemBuilder: (context, index) {
                          return ParkCard(park: parksRelaxare[index]);
                        },
                      ),
                      ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: parksJoaca.length,
                        itemBuilder: (context, index) {
                          return ParkCard(park: parksJoaca[index]);
                        },
                      ),
                      ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: parksFitness.length,
                        itemBuilder: (context, index) {
                          return ParkCard(park: parksFitness[index]);
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class ParkCard extends StatefulWidget {
  final Park park;

  const ParkCard({
    super.key,
    required this.park,
  });

  @override
  State<ParkCard> createState() => _ParkCardState();
}

class _ParkCardState extends State<ParkCard> {
  late int currentImageIndex;
  late PageController controller;

  @override
  void initState() {
    super.initState();

    currentImageIndex = widget.park.primaryImage - 1;
    controller = PageController(initialPage: currentImageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        "/gallery",
        arguments: {
          "startIndex": currentImageIndex,
          "images": widget.park.images,
          "title": widget.park.name,
          "id": widget.park.id,
          "type": "park",
          "primaryImage": widget.park.primaryImage,
          "externalLink": "",
        },
      ),
      child: Container(
        height: Responsive.safeBlockVertical * 55,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          boxShadow: const [bottomShadowMd],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                PageView.builder(
                  physics: ClampingScrollPhysics(),
                  controller: controller,
                  itemCount: widget.park.images.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return CachedApiImage(
                      imageUrl: widget.park.images[index],
                      cacheHeight: Responsive.safeBlockVertical * 55,
                      height: double.infinity,
                      width: double.infinity,
                      blurhash: widget.park.primaryImageBlurhash,
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List<Widget>.generate(widget.park.images.length, (int dotIndex) {
                                return Container(
                                  width: 20,
                                  height: 3,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(currentImageIndex == dotIndex ? 0.9 : 0.4),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.park.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
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
                                                colorFilter: ColorFilter.mode(
                                                  kBackgroundColor.withOpacity(0.85),
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                location.getDistance(widget.park.latitude, widget.park.longitude),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: kBackgroundColor.withOpacity(0.85),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 18,
                                ),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: IconButton(
                                    color: kForegroundColor,
                                    icon: Icon(
                                      CupertinoIcons.location_fill,
                                      size: 18,
                                      color: kBackgroundColor.withOpacity(0.85),
                                    ),
                                    onPressed: () => openMap(
                                      widget.park.latitude,
                                      widget.park.longitude,
                                      widget.park.name,
                                      context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
