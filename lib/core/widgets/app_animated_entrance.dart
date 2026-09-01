import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Lightweight fade/slide entrance with an optional capped stagger delay.
class AppAnimatedEntrance extends StatelessWidget {
  const AppAnimatedEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = const Offset(0, 16),
  });

  final Widget child;
  final int index;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final delay = AppMotion.stagger(index);
    final duration = AppMotion.resolve(context, AppMotion.base);
    if (duration == Duration.zero) return child;

    final total = delay + duration;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: AppMotion.linear,
      child: child,
      builder: (context, value, child) {
        final elapsed = total.inMicroseconds * value;
        final progress =
            ((elapsed - delay.inMicroseconds) / duration.inMicroseconds).clamp(
              0.0,
              1.0,
            );
        final curved = AppMotion.standard.transform(progress);
        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - curved), offset.dy * (1 - curved)),
            child: child,
          ),
        );
      },
    );
  }
}
