import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_strings.dart';
import '../theme/app_motion.dart';

/// Signature scan action with subtle breathing and tactile press feedback.
class ScanFab extends StatefulWidget {
  const ScanFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<ScanFab> createState() => _ScanFabState();
}

class _ScanFabState extends State<ScanFab>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(vsync: this, duration: AppMotion.idle);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncAnimation();
    } else {
      _controller.stop();
    }
  }

  void _syncAnimation() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final breathing = 1 + (_controller.value * 0.04);
        return AnimatedScale(
          scale: _pressed ? 0.92 : breathing,
          duration: AppMotion.resolve(context, AppMotion.instant),
          curve: AppMotion.standard,
          child: child,
        );
      },
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: FloatingActionButton(
          tooltip: AppStrings.scanTitle,
          onPressed: () {
            HapticFeedback.lightImpact();
            widget.onPressed();
          },
          child: const Icon(Icons.document_scanner),
        ),
      ),
    );
  }
}
