import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  final Widget child;

  const LikeAnimation({super.key, required this.child});

  @override
  State<LikeAnimation> createState() => LikeAnimationState();
}

class LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController likeAnimationController;

  void animate() {
    likeAnimationController
        .reverse()
        .then((_) => likeAnimationController.forward());
  }

  @override
  void initState() {
    super.initState();

    likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    likeAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(
          parent: likeAnimationController,
          curve: Curves.easeOut,
        ),
      ),
      child: widget.child,
    );
  }
}
