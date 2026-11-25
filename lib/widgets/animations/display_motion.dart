import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class DisplayMotionScope extends InheritedWidget {
  const DisplayMotionScope({
    super.key,
    required this.progress,
    required this.isOutgoing,
    required this.enabled,
    required super.child,
  });

  final Animation<double> progress;
  final bool isOutgoing;
  final bool enabled;

  @override
  bool updateShouldNotify(DisplayMotionScope oldWidget) =>
      progress != oldWidget.progress ||
      isOutgoing != oldWidget.isOutgoing ||
      enabled != oldWidget.enabled;
}

class DisplayMotion extends StatelessWidget {
  const DisplayMotion({
    super.key,
    this.position = 0,
    this.startScale = 0.8,
    required this.child,
  });

  final int position;
  final double startScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DisplayMotionScope>();
    final Animation<double> opacity;
    if (scope == null || !scope.enabled) {
      opacity = kAlwaysCompleteAnimation;
    } else {
      final progress = scope.progress.drive(
        CurveTween(
          curve: Interval(position * 0.11, 1, curve: Curves.easeOutCubic),
        ),
      );
      opacity = scope.isOutgoing ? ReverseAnimation(progress) : progress;
    }

    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(
        scale: opacity.drive(Tween<double>(begin: startScale, end: 1)),
        child: child,
      ),
    );
  }
}

class EquationAppearance extends StatelessWidget {
  const EquationAppearance({
    super.key,
    required this.hasEquation,
    required this.child,
  });

  final bool hasEquation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!hasEquation || MediaQuery.disableAnimationsOf(context)) return child;

    return PlayAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.scale(scale: 0.8 + 0.2 * progress, child: child),
      ),
    );
  }
}
