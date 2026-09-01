import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_google_section.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _googleLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  /// Set after a successful signup while "Confirm email" is enabled —
  /// swaps the form for a "check your email" notice.
  String? _pendingEmail;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _nameError = name.isEmpty ? AppStrings.fullNameEmpty : null;
      _emailError = email.isEmpty
          ? AppStrings.emailEmpty
          : !email.contains('@')
          ? AppStrings.emailInvalid
          : null;
      _passwordError = password.isEmpty
          ? AppStrings.passwordEmpty
          : password.length < 6
          ? AppStrings.passwordTooShort
          : null;
    });
    if (_nameError != null || _emailError != null || _passwordError != null) {
      return;
    }

    setState(() => _submitting = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .register(email, password, name);
    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold((failure) => _showSnackBar(failure.message), (user) {
      if (user.emailConfirmed) {
        // Confirmation disabled / already verified → session issued.
        context.go(RouteNames.dashboard);
      } else {
        setState(() => _pendingEmail = email);
      }
    });
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _googleLoading = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .loginWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    result.fold(
      (failure) => _showSnackBar(failure.message),
      (_) => context.go(RouteNames.dashboard),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingEmail != null) {
      return _ConfirmationView(
        email: _pendingEmail!,
        onBackToLogin: () => context.go(RouteNames.login),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(
                AppStrings.registerTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(AppStrings.registerSubtitle),
              const SizedBox(height: AppSpacing.xl),
              AuthTextField(
                label: AppStrings.fullNameLabel,
                hint: AppStrings.fullNameHint,
                controller: _nameController,
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AuthTextField(
                label: AppStrings.emailLabel,
                hint: AppStrings.emailHint,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AuthTextField(
                label: AppStrings.passwordLabel,
                hint: AppStrings.passwordHint,
                controller: _passwordController,
                obscure: true,
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: AppStrings.registerButton,
                isLoading: _submitting,
                expanded: true,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthGoogleSection(
                onTap: _loginWithGoogle,
                isLoading: _googleLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.alreadyHaveAccount),
                  TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: Text(AppStrings.loginButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Success state shown after registration while email confirmation is
/// pending ("Confirm email" enabled in Supabase).
class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({required this.email, required this.onBackToLogin});

  final String email;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 72,
                color: colors.success,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.checkEmailTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                email,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.checkEmailBody,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: AppStrings.backToLogin,
                expanded: true,
                onPressed: onBackToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
