import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/router/app_router.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_google_section.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _googleLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() {
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
    if (_emailError != null || _passwordError != null) return;
    setState(() => _submitting = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(email, password);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => _showSnackBar(failure.message),
      (_) => context.go(RouteNames.dashboard),
    );
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(
                AppStrings.loginTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(AppStrings.loginSubtitle),
              const SizedBox(height: AppSpacing.xl),
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
                label: AppStrings.loginButton,
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
                  Text(AppStrings.noAccountYet),
                  TextButton(
                    onPressed: () => context.go(RouteNames.register),
                    child: Text(AppStrings.registerButton),
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
