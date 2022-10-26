import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/widgets/like_animation.dart';

class GalleryView extends StatefulWidget {
  final int startIndex;
  final List<String> images;
  final String title;
  final String id;

  const GalleryView({
    super.key,
    required this.startIndex,
    required this.images,
    required this.title,
    required this.id,
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          widget.title,
          style: Theme.of(context)
              .textTheme
              .headline3!
              .copyWith(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.adaptive.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.adaptive.share),
          ),
          LikeAnimation(
            key: likeAnimationKey,
            child: Consumer<Wishlist>(
              builder: (context, favourites, _) {
                return IconButton(
                  splashRadius: 1,
                  onPressed: () {
                    favourites.toggleSightWishState(widget.id);
                    likeAnimationKey.currentState!.animate();
                  },
                  icon: Icon(
                    favourites.items['sights']!.contains(widget.id)
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: favourites.items['sights']!.contains(widget.id)
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
                    child: Image(image: NetworkImage(widget.images[index])),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
