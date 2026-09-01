import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/account_entity.dart';
import '../controllers/account_controller.dart';

/// Create/edit account form (TASKS.md 3C.3). Pass [account] to edit.
class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key, this.account});

  final AccountEntity? account;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  late final TextEditingController _nameController;
  late AccountType _type;
  late String _color;
  bool _submitting = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _type = widget.account?.accountType ?? AccountType.cash;
    _color = widget.account?.color ?? ColorPresets.hex.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(AppStrings.accountNameEmpty);
      return;
    }
    setState(() => _submitting = true);
    final controller = ref.read(accountControllerProvider.notifier);
    final result = widget.account == null
        ? await controller.create(name, _type, color: _color)
        : await controller.updateAccount(
            widget.account!.copyWith(
              name: name,
              accountType: _type,
              color: _color,
            ),
          );
    if (!mounted) return;
    if (result case Failure(:final failure)) {
      setState(() => _submitting = false);
      _showError(failure.message);
      return;
    }
    setState(() {
      _submitting = false;
      _saved = true;
    });
    await Future<void>.delayed(AppMotion.resolve(context, AppMotion.fast));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteAccountConfirmTitle),
        content: Text(AppStrings.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _submitting = true);
    final result = await ref
        .read(accountControllerProvider.notifier)
        .delete(widget.account!.id);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => _showError(failure.message),
      (_) => Navigator.of(context).pop(),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.account == null
              ? AppStrings.addAccount
              : AppStrings.editAccount,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.accountNameLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.accountTypeLabel,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<AccountType>(
              segments: [
                ButtonSegment(
                  value: AccountType.cash,
                  label: Text(AppStrings.accountCash),
                  icon: const Icon(Icons.payments),
                ),
                ButtonSegment(
                  value: AccountType.eWallet,
                  label: Text(AppStrings.accountEWallet),
                  icon: const Icon(Icons.wallet),
                ),
                ButtonSegment(
                  value: AccountType.bank,
                  label: Text(AppStrings.accountBank),
                  icon: const Icon(Icons.account_balance),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.edit,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: ColorPresets.hex
                  .map((hex) => _colorSwatch(hex, colors))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: AppStrings.save,
              isLoading: _submitting,
              isSuccess: _saved,
              expanded: true,
              onPressed: _saved ? null : _submit,
            ),
            if (widget.account != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton.destructive(
                label: AppStrings.delete,
                isLoading: _submitting,
                expanded: true,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _colorSwatch(String hex, AppColors colors) {
    final color = tryParseColor(hex)!;
    final selected = _color == hex;
    return AnimatedScale(
      scale: selected ? 1.12 : 1,
      duration: AppMotion.resolve(context, AppMotion.fast),
      curve: AppMotion.emphasized,
      child: InkWell(
        onTap: () => setState(() => _color = hex),
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: AppMotion.resolve(context, AppMotion.fast),
          curve: AppMotion.standard,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.textPrimary : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
