import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../../core/widgets/app_button.dart';

/// Round account chip for the horizontal selector (DESIGN.md §5.5).
class AccountSelectorChip extends StatelessWidget {
  const AccountSelectorChip({
    super.key,
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final AccountEntity account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = tryParseColor(account.color) ?? colors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.18)
              : colors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconForName(account.icon), size: 16, color: accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              account.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full transaction editor shared by manual entry, edit, and the OCR
/// quick-edit flow (DESIGN.md §5.4, TASKS.md 6C.4). Fields prefilled from
/// [initial] (e.g. scan results); failed OCR fields stay empty and are
/// highlighted for manual input.
class QuickEditForm extends ConsumerStatefulWidget {
  const QuickEditForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.onSubmit,
    this.isLoading = false,
    this.isSuccess = false,
  });

  final TransactionEntity? initial;
  final String submitLabel;
  final bool isLoading;
  final bool isSuccess;
  final void Function(TransactionEntity transaction) onSubmit;

  @override
  ConsumerState<QuickEditForm> createState() => _QuickEditFormState();
}

class _QuickEditFormState extends ConsumerState<QuickEditForm> {
  late TransactionType _type;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _merchantController;
  late DateTime _date;
  String? _accountId;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial?.type ?? TransactionType.expense;
    _amountController = TextEditingController(
      text: (initial?.amount ?? 0) > 0
          ? _formatDigits(initial!.amount.round().toString())
          : '',
    );
    _noteController = TextEditingController(text: initial?.note ?? '');
    _merchantController = TextEditingController(text: initial?.merchant ?? '');
    _date = initial?.date ?? DateTime.now();
    _accountId = (initial?.accountId.isNotEmpty ?? false)
        ? initial!.accountId
        : null;
    _categoryId = (initial?.categoryId.isNotEmpty ?? false)
        ? initial!.categoryId
        : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  String _formatDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
    }
    return buffer.toString();
  }

  double get _amount {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) ?? 0;
  }

  void _onAmountChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = digits.isEmpty ? '' : _formatDigits(digits);
    if (formatted != value) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    // Always explain WHY saving is blocked — a silently disabled button made
    // users believe the transaction was saved (no request ever left the
    // device, hence zero Supabase logs).
    final messenger = ScaffoldMessenger.of(context);
    if (_amount <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.amountInvalid)),
      );
      return;
    }
    final accounts =
        ref.read(accountControllerProvider).valueOrNull ??
        const <AccountEntity>[];
    if (_accountId == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            accounts.isEmpty
                ? AppStrings.noAccountsAvailable
                : AppStrings.accountRequired,
          ),
        ),
      );
      return;
    }
    final categories =
        ref.read(categoryControllerProvider).valueOrNull ??
        const <CategoryEntity>[];
    final typeCategories = categories
        .where((c) => c.transactionType == _type)
        .toList();
    if (_categoryId == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            typeCategories.isEmpty
                ? AppStrings.noCategoriesAvailable
                : AppStrings.categoryRequired,
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final initial = widget.initial;
    widget.onSubmit(
      TransactionEntity(
        id: initial?.id ?? '',
        userId: initial?.userId ?? '',
        accountId: _accountId!,
        categoryId: _categoryId!,
        type: _type,
        amount: _amount,
        date: DateTime(_date.year, _date.month, _date.day),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        merchant: _merchantController.text.trim().isEmpty
            ? null
            : _merchantController.text.trim(),
        source: initial?.source ?? 'manual',
        syncStatus: initial?.syncStatus ?? SyncStatus.pendingSync,
        createdAt: initial?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accountsAsync = ref.watch(accountControllerProvider);
    final categoriesAsync = ref.watch(categoryControllerProvider);

    final accounts = accountsAsync.valueOrNull ?? const <AccountEntity>[];
    final categories = categoriesAsync.valueOrNull ?? const <CategoryEntity>[];
    final typeCategories = categories
        .where((c) => c.transactionType == _type)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: AppMotion.resolve(context, AppMotion.base),
            curve: AppMotion.standard,
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color:
                  (_type == TransactionType.income
                          ? colors.success
                          : colors.surfaceElevated)
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(AppStrings.expense),
                  icon: const Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(AppStrings.income),
                  icon: const Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() {
                final newType = selection.first;
                _type = newType;
                if (_categoryId != null &&
                    !categories.any(
                      (c) =>
                          c.id == _categoryId && c.transactionType == newType,
                    )) {
                  _categoryId = null;
                }
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: _onAmountChanged,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              labelText: AppStrings.amountLabel,
              prefixText: 'Rp ',
              hintText: '0',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Merchant field — highlighted when OCR failed to detect it.
          TextField(
            controller: _merchantController,
            decoration: InputDecoration(
              labelText: AppStrings.merchantLabel,
              hintText:
                  (widget.initial?.source != null &&
                      widget.initial?.source != 'manual' &&
                      (widget.initial?.merchant ?? '').isEmpty)
                  ? AppStrings.notDetected
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(
                  color:
                      (widget.initial?.source != null &&
                          widget.initial?.source != 'manual' &&
                          (widget.initial?.merchant ?? '').isEmpty)
                      ? colors.warning
                      : Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: AppStrings.dateLabel,
              ),
              child: Text(
                '${_date.day}/${_date.month}/${_date.year}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppStrings.accountLabel,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (accounts.isEmpty)
            // Silent disabled submit confused users with no default rows;
            // make the blocker visible instead (TASKS.md 9.5).
            Text(
              AppStrings.noAccountsAvailable,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.warning),
            )
          else
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) => AccountSelectorChip(
                  account: accounts[index],
                  selected: _accountId == accounts[index].id,
                  onTap: () => setState(() => _accountId = accounts[index].id),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _categoryId,
            decoration: const InputDecoration(
              labelText: AppStrings.categoryLabel,
            ),
            items: typeCategories
                .map(
                  (category) => DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(
                          iconForName(category.icon),
                          size: 18,
                          color:
                              tryParseColor(category.color) ?? colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(category.name),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _categoryId = value),
          ),
          if (typeCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                AppStrings.noCategoriesAvailable,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.warning),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: AppStrings.noteLabel,
              hintText: AppStrings.noteHint,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton.primary(
            label: widget.submitLabel,
            // Never silently disabled — validation errors are surfaced as
            // snackbars in _submit() so the user always knows what blocks
            // the save.
            onPressed: (!widget.isLoading && !widget.isSuccess)
                ? _submit
                : null,
            isLoading: widget.isLoading,
            isSuccess: widget.isSuccess,
            expanded: true,
          ),
        ],
      ),
    );
  }
}
