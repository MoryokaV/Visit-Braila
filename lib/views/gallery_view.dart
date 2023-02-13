import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visit_braila/models/event_model.dart';
import 'package:visit_braila/models/sight_model.dart';
import 'package:visit_braila/models/tour_model.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/services/dynamic_links_service.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/like_animation.dart';

class GalleryView extends StatefulWidget {
  final int startIndex;
  final Sight? sight;
  final Tour? tour;
  final Event? event;

  const GalleryView({
    super.key,
    required this.startIndex,
    required this.sight,
    required this.tour,
    required this.event,
  });

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late int selectedIndex;
  late final PageController pageController;
  late final Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.startIndex;
    collectData();
  }

  void collectData() {
    if (widget.sight != null) {
      data = {
        "images": widget.sight!.images,
        "title": widget.sight!.name,
        "id": widget.sight!.id,
        "collection": "sights",
        "type": "sight",
        "primaryImage": widget.sight!.primaryImage,
        "externalLink": widget.sight!.externalLink,
      };
    } else if (widget.tour != null) {
      data = {
        "images": widget.tour!.images,
        "title": widget.tour!.name,
        "id": widget.tour!.id,
        "collection": "tours",
        "type": "tour",
        "primaryImage": widget.tour!.primaryImage,
        "externalLink": widget.tour!.externalLink,
      };
    } else if (widget.event != null) {
      data = {
        "images": widget.event!.images,
        "title": widget.event!.name,
        "id": widget.event!.id,
        "collection": "",
        "type": "event",
        "primaryImage": widget.event!.primaryImage,
        "externalLink": widget.event!.externalLink,
      };
    } else {
      data = {};
    }
  }

  final likeAnimationKey = GlobalKey<LikeAnimationState>();
  final double separator = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          data['title'],
          style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.adaptive.arrow_back),
        ),
        actions: [
          IconButton(
            splashRadius: 1,
            onPressed: () async {
              final link = await DynamicLinksService.generateDynamicLink(
                id: data['id'],
                image: data['images'][data['primaryImage'] - 1],
                name: data['title'],
                collection: data['type'],
                alternativeUrl: data['externalLink'],
              );

              Share.share(link.toString());
            },
            icon: Icon(Icons.adaptive.share),
          ),
          if (widget.sight != null || widget.tour != null)
            LikeAnimation(
              key: likeAnimationKey,
              child: Consumer<Wishlist>(
                builder: (context, wishlist, _) {
                  return IconButton(
                    splashRadius: 1,
                    onPressed: () {
                      data['collection'] == "sights"
                          ? wishlist.toggleSightWishState(data['id'])
                          : wishlist.toggleTourWishState(data['id']);
                      likeAnimationKey.currentState!.animate();
                    },
                    icon: Icon(
                      wishlist.items[data['collection']]!.contains(data['id'])
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: wishlist.items[data['collection']]!.contains(data['id'])
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.white,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: data['images'].length,
              pageController: PageController(
                initialPage: selectedIndex,
                viewportFraction: 1 + (separator * 2 / Responsive.screenWidth),
              ),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions.customChild(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: separator),
                    child: CachedApiImage(
                      imageUrl: data['images'][index],
                      fit: BoxFit.contain,
                      cacheWidth: Responsive.screenWidth * 1.8,
                      blur: false,
                    ),
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 3.5,
                );
              },
              onPageChanged: (index) => setState(() => selectedIndex = index),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "${selectedIndex + 1}  —  ${data['images'].length}",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
