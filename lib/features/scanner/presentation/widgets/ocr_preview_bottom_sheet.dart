import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/scan_result_entity.dart';

/// OCR result preview (TASKS.md 6C.3, DESIGN.md §5.3). Never auto-saves —
/// the user confirms everything in the Quick Edit Form (PRD.md §6.4).
class OcrPreviewBottomSheet extends ConsumerStatefulWidget {
  const OcrPreviewBottomSheet({super.key, required this.result});

  final ScanResultEntity result;

  @override
  ConsumerState<OcrPreviewBottomSheet> createState() =>
      _OcrPreviewBottomSheetState();
}

class _OcrPreviewBottomSheetState extends ConsumerState<OcrPreviewBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.reveal);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && !_controller.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Source name ('gopay') matched against account names for preselection.
  String? _matchedAccountId(WidgetRef ref) {
    final accounts = ref.read(accountControllerProvider).valueOrNull;
    if (accounts == null || widget.result.source == null) return null;
    final source = widget.result.source!.replaceAll('_', ' ');
    return accounts
        .where(
          (account) =>
              account.name.toLowerCase().contains(source.toLowerCase()),
        )
        .firstOrNull
        ?.id;
  }

  TransactionEntity _toDraft(WidgetRef ref) {
    final now = DateTime.now();
    return TransactionEntity(
      id: '',
      userId: '',
      accountId: _matchedAccountId(ref) ?? '',
      categoryId: '',
      type: widget.result.type ?? TransactionType.expense,
      amount: widget.result.amount ?? 0,
      date: widget.result.date ?? DateTime.now(),
      merchant: widget.result.merchant,
      source: widget.result.source ?? 'manual',
      syncStatus: SyncStatus.pendingSync,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final result = widget.result;
    final amount = result.amount;
    final merchant = result.merchant;
    final date = result.date;
    final confident = amount != null && merchant != null && date != null;
    final hasAmount = amount != null && amount > 0;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.scanResultTitle, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: confident ? AppMotion.emphasized : AppMotion.standard,
                ),
                child: RotationTransition(
                  turns: Tween(
                    begin: confident ? -0.08 : 0.0,
                    end: 0.0,
                  ).animate(_controller),
                  child: Icon(
                    confident ? Icons.check_circle : Icons.document_scanner,
                    size: 40,
                    color: confident ? colors.success : colors.warning,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _reveal(
                  index: 0,
                  horizontal: true,
                  child: Text(
                    confident
                        ? AppStrings.detectedAutomatically
                        : AppStrings.needsReview,
                    style: textTheme.labelSmall?.copyWith(
                      color: confident ? colors.success : colors.warning,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _reveal(
            index: 1,
            child: amount == null
                ? _missingField(context, AppStrings.amountLabel)
                : Text(
                    CurrencyFormatter.format(amount),
                    style: textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _reveal(
            index: 2,
            child: _fieldRow(
              context,
              label: AppStrings.dateLabel,
              value: date == null ? null : DateFormatter.format(date),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _reveal(
            index: 3,
            child: _fieldRow(
              context,
              label: AppStrings.merchantLabel,
              value: merchant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _reveal(
            index: 4,
            child: _fieldRow(
              context,
              label: AppStrings.transactionTypeLabel,
              value: result.type == TransactionType.income
                  ? AppStrings.income
                  : AppStrings.expense,
            ),
          ),
          if (result.source != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _reveal(
              index: 5,
              child: _fieldRow(
                context,
                label: AppStrings.sourceLabel,
                value: result.source,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: AppStrings.saveTransaction,
            leadingIcon: Icons.check,
            expanded: true,
            // Per PRD.md §5.2 the save flow continues in the Quick Edit Form
            // where account & category are confirmed.
            onPressed: hasAmount
                ? () => Navigator.of(context).pop(_toDraft(ref))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _reveal({
    required int index,
    required Widget child,
    bool horizontal = false,
  }) {
    final start = (0.08 + (index * 0.09)).clamp(0.0, 0.75);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: AppMotion.standard),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: horizontal ? const Offset(-0.08, 0) : const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _fieldRow(
    BuildContext context, {
    required String label,
    required String? value,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value ?? AppStrings.notDetected,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: value == null ? colors.warning : colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _missingField(BuildContext context, String label) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors.warning),
      ),
      child: Text(
        '$label: ${AppStrings.notDetected}',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
