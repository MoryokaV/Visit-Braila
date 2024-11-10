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
  final String? collection;
  final String text;
  final String link;
  final String? phone;

  ActionsBar({
    super.key,
    required this.id,
    this.collection,
    required this.text,
    required this.link,
    this.phone,
  });

  final likeAnimationLeftKey = GlobalKey<LikeAnimationState>();
  final likeAnimationRightKey = GlobalKey<LikeAnimationState>();

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
            if (phone != null)
              LikeAnimation(
                key: likeAnimationLeftKey,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [globalShadow],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: IconButton(
                    splashRadius: 1,
                    onPressed: () {
                      openTel(phone!);
                      likeAnimationLeftKey.currentState!.animate();
                    },
                    icon: const Icon(
                      CupertinoIcons.phone,
                      color: kForegroundColor,
                    ),
                  ),
                ),
              ),
            if (phone != null)
              const SizedBox(
                width: 6,
              ),
            Expanded(
              child: ElevatedButton(
                onPressed: () => openBrowserURL(link),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  textStyle: Theme.of(context).textTheme.labelLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(phone == null ? 10 : 0),
                      bottomLeft: Radius.circular(phone == null ? 10 : 0),
                      topRight: Radius.circular(collection == null ? 10 : 0),
                      bottomRight: Radius.circular(collection == null ? 10 : 0),
                    ),
                  ),
                ),
                child: Text(text),
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            if (collection != null)
              LikeAnimation(
                key: likeAnimationRightKey,
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
                          switch (collection) {
                            case "sights":
                              wishlist.toggleSightWishState(id);
                              break;
                            case "tours":
                              wishlist.toggleTourWishState(id);
                              break;
                            case "restaurants":
                              wishlist.toggleRestaurantWishState(id);
                              break;
                            case "hotels":
                              wishlist.toggleHotelWishState(id);
                              break;
                          }

                          likeAnimationRightKey.currentState!.animate();
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
