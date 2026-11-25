import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.position,
    this.columnCount,
    required this.child,
  });

  final int position;
  final int? columnCount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    const duration = Duration(milliseconds: 200);
    const delay = Duration(milliseconds: 18);
    final entrance = ScaleAnimation(
      scale: 0.8,
      curve: Curves.easeOutCubic,
      child: FadeInAnimation(curve: Curves.easeOut, child: child),
    );

    final columns = columnCount;
    if (columns != null) {
      return AnimationConfiguration.staggeredGrid(
        columnCount: columns,
        position: position,
        duration: duration,
        delay: delay,
        child: entrance,
      );
    }

    return AnimationConfiguration.staggeredList(
      position: position.clamp(0, 8),
      duration: duration,
      delay: delay,
      child: entrance,
    );
  }
}
