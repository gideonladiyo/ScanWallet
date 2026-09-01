import 'package:flutter/material.dart';

/// Shared motion tokens for every presentation-layer animation.
class AppMotion {
  const AppMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration reveal = Duration(milliseconds: 600);
  static const Duration scan = Duration(milliseconds: 1400);
  static const Duration idle = Duration(milliseconds: 1800);
  static const Duration float = Duration(milliseconds: 2400);

  static const Duration staggerStep = Duration(milliseconds: 40);
  static const int staggerMaxItems = 12;

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
  static const Curve exit = Curves.easeInCubic;
  static const Curve linear = Curves.linear;

  static Duration resolve(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }

  static Duration stagger(int index) {
    return staggerStep * index.clamp(0, staggerMaxItems);
  }
}
