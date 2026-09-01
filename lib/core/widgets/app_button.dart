import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../theme/app_motion.dart';

enum AppButtonVariant { primary, secondary, destructive }

/// Design-system button (DESIGN.md §5.1). Loading swaps label for a spinner
/// without changing the button size (prevents layout shift).
class AppButton extends StatefulWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.expanded = false,
    this.isSuccess = false,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.expanded = false,
    this.isSuccess = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.expanded = false,
    this.isSuccess = false,
  }) : variant = AppButtonVariant.destructive;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final bool expanded;
  final bool isSuccess;
  final AppButtonVariant variant;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final disabled =
        widget.onPressed == null || widget.isLoading || widget.isSuccess;

    final (backgroundColor, foregroundColor, side) = switch (widget.variant) {
      AppButtonVariant.primary => (
        colors.primary,
        Colors.white,
        BorderSide.none,
      ),
      AppButtonVariant.secondary => (
        Colors.transparent,
        colors.primary,
        BorderSide(color: colors.primary),
      ),
      AppButtonVariant.destructive => (
        colors.error,
        Colors.white,
        BorderSide.none,
      ),
    };

    final child = AnimatedSwitcher(
      duration: AppMotion.resolve(context, AppMotion.fast),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: widget.isLoading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : widget.isSuccess
          ? const Icon(Icons.check, key: ValueKey('success'), size: 22)
          : Row(
              key: ValueKey(widget.label),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.leadingIcon != null) ...[
                  Icon(widget.leadingIcon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(widget.label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
    );

    final button = TextButton(
      onPressed: disabled ? null : widget.onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => widget.isSuccess
              ? colors.success
              : states.contains(WidgetState.disabled)
              ? colors.surfaceElevated
              : backgroundColor,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => widget.isSuccess
              ? Colors.white
              : states.contains(WidgetState.disabled)
              ? colors.textSecondary
              : foregroundColor,
        ),
        side: WidgetStatePropertyAll(side),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
      ),
      child: child,
    );

    final scaled = Listener(
      onPointerDown: disabled ? null : (_) => setState(() => _pressed = true),
      onPointerUp: disabled ? null : (_) => setState(() => _pressed = false),
      onPointerCancel: disabled
          ? null
          : (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: AppMotion.resolve(context, AppMotion.instant),
        curve: AppMotion.standard,
        child: button,
      ),
    );
    return widget.expanded
        ? SizedBox(width: double.infinity, child: scaled)
        : scaled;
  }
}

/// Round icon-only button (DESIGN.md §5.1 icon variant). [tooltip] is
/// required so screen readers always have a label (DESIGN.md §7).
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 48,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Tooltip(
      message: widget.tooltip,
      child: Listener(
        onPointerDown: widget.onPressed == null
            ? null
            : (_) => setState(() => _pressed = true),
        onPointerUp: widget.onPressed == null
            ? null
            : (_) => setState(() => _pressed = false),
        onPointerCancel: widget.onPressed == null
            ? null
            : (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1,
          duration: AppMotion.resolve(context, AppMotion.instant),
          curve: AppMotion.standard,
          child: Material(
            color: widget.backgroundColor ?? colors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Icon(
                  widget.icon,
                  color: widget.foregroundColor ?? Colors.white,
                  size: widget.size * 0.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
