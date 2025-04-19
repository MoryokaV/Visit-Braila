import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visit_braila/controllers/sight_controller.dart';
import 'package:visit_braila/models/personality_model.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/services/dynamic_links_service.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/actions_bar.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/html_description.dart';
import 'dart:io' show Platform;

import 'package:visit_braila/widgets/loading_spinner.dart';

class PersonalityView extends StatefulWidget {
  final Personality personality;
  final String? sightName;
  final Animation<double> routeAnimation;

  const PersonalityView({
    super.key,
    required this.personality,
    this.sightName,
    required this.routeAnimation,
  });

  @override
  State<PersonalityView> createState() => _PersonalityViewState();
}

class _PersonalityViewState extends State<PersonalityView> {
  bool isLoading = false;

  final SightController sightController = SightController();

  void openSightLink(String id) async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    Sight? sight = await sightController.findSight(id);

    sight != null ? navigateToSightView(sight) : navigateNotFoundView();

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
        id: widget.personality.id,
        text: "Află mai multe",
        link: widget.personality.pdf,
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
                      "startIndex": widget.personality.primaryImage - 1,
                      "images": widget.personality.images,
                      "title": widget.personality.name,
                      "id": widget.personality.id,
                      "type": "personality",
                      "primaryImage": widget.personality.primaryImage,
                      "externalLink": widget.personality.pdf,
                    },
                  ),
                  child: Hero(
                    tag: widget.personality.id,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedApiImage(
                          imageUrl: widget.personality.images[widget.personality.primaryImage - 1],
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
                  CircleAvatar(
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
                          id: widget.personality.id,
                          image: widget.personality.images[widget.personality.primaryImage - 1],
                          name: widget.personality.name,
                          collection: "personality",
                          alternativeUrl: widget.personality.pdf,
                        );

                        Share.share(link.toString());
                      },
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? const SliverFillRemaining(
                    child: LoadingSpinner(),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: widget.routeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.personality.name,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (widget.sightName != null)
                              RichText(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Vezi și ${widget.sightName}",
                                      recognizer: (TapGestureRecognizer()
                                        ..onTap = () => openSightLink(widget.personality.sightLink!)),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.4,
                                        color: kPrimaryColor,
                                        decoration: TextDecoration.underline,
                                        decorationColor: kPrimaryColor,
                                        fontFamily: labelFont,
                                      ),
                                    ),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.bottom,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: SvgPicture.asset(
                                          "assets/icons/open-window.svg",
                                          width: 16,
                                          colorFilter: const ColorFilter.mode(kPrimaryColor, BlendMode.srcIn),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Prezentare generală",
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                    color: kForegroundColor.withAlpha(180),
                                    fontSize: 18,
                                  ),
                            ),
                            HtmlDescription(
                              data: widget.personality.description,
                              shrink: true,
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            SizedBox(
                              height: Responsive.safeBlockHorizontal * 35,
                              child: ListView.separated(
                                itemCount: widget.personality.images.length > 4 ? 5 : widget.personality.images.length,
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
                                        "images": widget.personality.images,
                                        "title": widget.personality.name,
                                        "id": widget.personality.id,
                                        "type": "personality",
                                        "primaryImage": widget.personality.primaryImage,
                                        "externalLink": widget.personality.pdf,
                                      },
                                    ),
                                    child: index != 4
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: CachedApiImage(
                                              imageUrl: widget.personality.images[index],
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
                                                "+${widget.personality.images.length - 4}",
                                                style:
                                                    Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 24),
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
                              parent: widget.routeAnimation,
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
