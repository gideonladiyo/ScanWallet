import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';

/// Labeled text field with visibility toggle for passwords
/// (TASKS.md 2C.4). Trivial local UI state only.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.autocorrect = false,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField>
    with SingleTickerProviderStateMixin {
  bool _obscured = true;
  late final FocusNode _focusNode;
  late final AnimationController _shakeController;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
    _shakeController = AnimationController(
      vsync: this,
      duration: AppMotion.base,
    );
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && widget.errorText != oldWidget.errorText) {
      if (!MediaQuery.disableAnimationsOf(context)) {
        _shakeController.forward(from: 0);
      }
    }
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isPassword = widget.obscure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: AppSpacing.sm),
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shake.value, 0),
            child: child,
          ),
          child: AnimatedContainer(
            duration: AppMotion.resolve(context, AppMotion.fast),
            curve: AppMotion.standard,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: _focusNode.hasFocus && widget.errorText == null
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.16),
                        blurRadius: 12,
                      ),
                    ]
                  : const [],
            ),
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              obscureText: isPassword && _obscured,
              keyboardType: widget.keyboardType,
              autocorrect: widget.autocorrect,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hint,
                errorText: widget.errorText,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide(color: colors.primary, width: 2),
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        tooltip: _obscured
                            ? AppStrings.showPassword
                            : AppStrings.hidePassword,
                        onPressed: () => setState(() => _obscured = !_obscured),
                        icon: Icon(
                          _obscured ? Icons.visibility_off : Icons.visibility,
                          color: colors.textSecondary,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
