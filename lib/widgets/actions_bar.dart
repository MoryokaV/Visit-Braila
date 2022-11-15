import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/utils/url_constants.dart';
import 'package:visit_braila/widgets/like_animation.dart';

class ActionsBar extends StatelessWidget {
  final String id;
  final String collection;
  final String link;

  ActionsBar({
    super.key,
    required this.id,
    required this.collection,
    required this.link,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 14,
        left: Responsive.screenWidth / 8,
        right: Responsive.screenWidth / 8,
        bottom: Responsive.safePaddingBottom != 0 ? Responsive.safePaddingBottom : 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [topShadow],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => openBrowserURL(link),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  textStyle: Theme.of(context).textTheme.button,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
                child: Text(collection == "sights" ? "Vizitează acum" : "Fă turul"),
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            LikeAnimation(
              key: likeAnimationKey,
              child: Consumer<Wishlist>(
                builder: (context, wishlist, _) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [globalShadow],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: IconButton(
                      splashRadius: 1,
                      onPressed: () {
                        collection == "sights" ? wishlist.toggleSightWishState(id) : wishlist.toggleTourWishState(id);
                        likeAnimationKey.currentState!.animate();
                      },
                      icon: Icon(
                        wishlist.items[collection]!.contains(id) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                        color: wishlist.items[collection]!.contains(id)
                            ? Theme.of(context).colorScheme.secondary
                            : kForegroundColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
