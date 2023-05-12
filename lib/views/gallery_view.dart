import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/services/dynamic_links_service.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/widgets/cached_image.dart';
import 'package:visit_braila/widgets/like_animation.dart';

class GalleryView extends StatefulWidget {
  final int startIndex;
  final List<String> images;
  final String title;
  final String id;
  final String? collection;
  final String type;
  final int primaryImage;
  final String externalLink;

  const GalleryView({
    super.key,
    required this.startIndex,
    required this.images,
    required this.title,
    required this.id,
    this.collection,
    required this.type,
    required this.primaryImage,
    required this.externalLink,
  });

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late int selectedIndex;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.startIndex;
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
          widget.title,
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
                id: widget.id,
                image: widget.images[widget.primaryImage - 1],
                name: widget.title,
                collection: widget.type,
                alternativeUrl: widget.externalLink,
              );

              Share.share(link.toString());
            },
            icon: Icon(Icons.adaptive.share),
          ),
          if (widget.collection != null)
            LikeAnimation(
              key: likeAnimationKey,
              child: Consumer<Wishlist>(
                builder: (context, wishlist, _) {
                  return IconButton(
                    splashRadius: 1,
                    onPressed: () {
                      switch (widget.collection) {
                        case "sights":
                          wishlist.toggleSightWishState(widget.id);
                          break;
                        case "tours":
                          wishlist.toggleTourWishState(widget.id);
                          break;
                        case "restaurants":
                          wishlist.toggleRestaurantWishState(widget.id);
                          break;
                        case "hotels":
                          wishlist.toggleHotelWishState(widget.id);
                          break;
                      }

                      likeAnimationKey.currentState!.animate();
                    },
                    icon: Icon(
                      wishlist.items[widget.collection]!.contains(widget.id)
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: wishlist.items[widget.collection]!.contains(widget.id)
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
              itemCount: widget.images.length,
              pageController: PageController(
                initialPage: selectedIndex,
                viewportFraction: 1 + (separator * 2 / Responsive.screenWidth),
              ),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions.customChild(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: separator),
                    child: CachedApiImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      cacheWidth: Responsive.screenWidth * 1.8,
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
                  "${selectedIndex + 1}  —  ${widget.images.length}",
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
