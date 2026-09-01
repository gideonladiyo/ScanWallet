import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../scanner/presentation/widgets/quick_edit_form.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/transaction_controller.dart';

/// Manual entry & edit form (TASKS.md 5C.3). Wraps the shared QuickEditForm;
/// the same screen is reused prefilled from a scan result.
class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.initial});

  final TransactionEntity? initial;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  bool _submitting = false;
  bool _saved = false;

  Future<void> _save(TransactionEntity transaction) async {
    setState(() => _submitting = true);
    final controller = ref.read(transactionControllerProvider.notifier);
    final isEdit = transaction.id.isNotEmpty;
    final result = isEdit
        ? await controller.updateTransaction(transaction)
        : await controller.create(transaction);
    if (!mounted) return;
    if (result case Failure(:final failure)) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
      return;
    }
    if (result case Success<TransactionEntity>(
      data: final savedTransaction,
    ) when savedTransaction.syncStatus == SyncStatus.pendingSync) {
      setState(() => _submitting = false);
      final colors = Theme.of(context).extension<AppColors>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colors.warning,
          content: Text(
            AppStrings.savedOffline,
            style: TextStyle(color: colors.background),
          ),
        ),
      );
      Navigator.of(context).pop();
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
    final id = widget.initial?.id;
    if (id == null || id.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteTransactionConfirmTitle),
        content: Text(AppStrings.deleteTransactionConfirmMessage),
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
        .read(transactionControllerProvider.notifier)
        .delete(id);
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = (widget.initial?.id ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? AppStrings.editTransaction : AppStrings.addTransaction,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: QuickEditForm(
              initial: widget.initial,
              submitLabel: AppStrings.save,
              isLoading: _submitting,
              isSuccess: _saved,
              onSubmit: _save,
            ),
          ),
          if (isEdit)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton.destructive(
                label: AppStrings.delete,
                isLoading: _submitting,
                expanded: true,
                onPressed: _delete,
              ),
            ),
        ],
      ),
    );
  }
}
