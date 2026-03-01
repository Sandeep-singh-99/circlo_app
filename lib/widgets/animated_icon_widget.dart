import 'package:flutter/material.dart';

class AnimatedIconWidget extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AnimatedIconWidget({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Transform.scale(scale: animation.value, child: child),
    );
  }
}
