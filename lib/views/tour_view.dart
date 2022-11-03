import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/actions_bar.dart';
import 'package:visit_braila/widgets/html_description.dart';
import 'dart:io' show HttpException, Platform;

import 'package:visit_braila/widgets/loading_spinner.dart';

class TourView extends StatefulWidget {
  final Tour tour;
  final Animation<double> routeAnimation;

  const TourView({
    super.key,
    required this.tour,
    required this.routeAnimation,
  });

  @override
  State<TourView> createState() => _TourViewState();
}

class _TourViewState extends State<TourView> {
  bool isLoading = false;

  final SightController sightController = SightController();

  void openSightLink(String id) async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      Sight sight = await sightController.findSight(id);

      navigateToSightView(sight);
    } on HttpException {
      navigateNotFoundView();
    }

    setState(() => isLoading = false);
  }

  void navigateToSightView(Sight sight) {
    Navigator.pushNamed(context, "/sight", arguments: sight);
  }

  void navigateNotFoundView() {
    Navigator.pushNamed(context, "/error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ActionsBar(
        id: widget.tour.id,
        collection: "tours",
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
                  tag: widget.tour.id,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.tour.images[widget.tour.primaryImage - 1],
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
              child: isLoading
                  ? SizedBox(
                      height: Responsive.safeBlockVertical * 36,
                      child: const LoadingSpinner(),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        child: AnimatedBuilder(
                          animation: widget.routeAnimation,
                          builder: (context, _) {
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: widget.routeAnimation,
                                curve: const Interval(0.6, 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.tour.name,
                                    style: Theme.of(context).textTheme.headline1,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/route.svg",
                                        width: 24,
                                        color: kPrimaryColor,
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      const Text(
                                        "N/A lungime",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  buildStagesRow(),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  HtmlDescription(
                                    data: widget.tour.description,
                                  ),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  SizedBox(
                                    height: Responsive.safeBlockHorizontal * 35,
                                    child: ListView.separated(
                                      itemCount: widget.tour.images.length > 4 ? 5 : widget.tour.images.length,
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
                                              "images": widget.tour.images,
                                              "title": widget.tour.name,
                                              "id": widget.tour.id,
                                              "collection": "tours",
                                            },
                                          ),
                                          child: index != 4
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.network(
                                                    widget.tour.images[index],
                                                    fit: BoxFit.cover,
                                                    width: Responsive.safeBlockVertical * 25,
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
                                                      "+${widget.tour.images.length - 4}",
                                                      style:
                                                          Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24),
                                                    ),
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

  Widget buildStagesRow() {
    return RichText(
      text: TextSpan(
        children: widget.tour.stages.map((stage) {
          bool isLink = stage.sightLink.isNotEmpty;
          bool isLast = widget.tour.stages.last != stage;

          return TextSpan(
            text: stage.text,
            recognizer: isLink ? (TapGestureRecognizer()..onTap = () => openSightLink(stage.sightLink)) : null,
            style: isLink
                ? TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  )
                : null,
            children: isLast
                ? const [
                    TextSpan(
                      text: " - ",
                      style: TextStyle(
                        color: kForegroundColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ]
                : null,
          );
        }).toList(),
        style: const TextStyle(
          fontFamily: bodyFont,
          color: kForegroundColor,
          fontSize: 14,
        ),
      ),
    );
  }
}
