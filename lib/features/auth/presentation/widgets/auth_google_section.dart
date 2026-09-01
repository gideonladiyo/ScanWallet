import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';

/// "Continue with Google" button + "atau" divider shared by login/register.
class AuthGoogleSection extends StatelessWidget {
  const AuthGoogleSection({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                AppStrings.orDivider,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton.secondary(
          label: AppStrings.googleButton,
          leadingIcon: Icons.login,
          expanded: true,
          isLoading: isLoading,
          onPressed: onTap,
        ),
      ],
    );
  }
}
