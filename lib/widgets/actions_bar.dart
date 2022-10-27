import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visit_braila/providers/wishlist_provider.dart';
import 'package:visit_braila/utils/responsive.dart';
import 'package:visit_braila/utils/style.dart';
import 'package:visit_braila/widgets/like_animation.dart';

class ActionsBar extends StatelessWidget {
  final String id;
  final String collection;

  ActionsBar({
    super.key,
    required this.id,
    required this.collection,
  });

  final likeAnimationKey = GlobalKey<LikeAnimationState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [topShadow],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: Responsive.screenWidth / 8,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                  child: const Text("Vizitează acum"),
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
      ),
    );
  }
}
