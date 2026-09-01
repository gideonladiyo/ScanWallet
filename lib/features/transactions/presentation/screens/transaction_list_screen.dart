import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_animated_entrance.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton_loader.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_list_item.dart';

/// Transaction history grouped by day (TASKS.md 5C.2). Filter toggle is
/// trivial local UI state.
class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  TransactionType? _filter;
  bool _syncing = false;

  Future<void> _syncNow() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final result = await ref
        .read(transactionControllerProvider.notifier)
        .syncPending();
    ref.invalidate(transactionControllerProvider);
    if (!mounted) return;
    setState(() => _syncing = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (count) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0 ? AppStrings.syncComplete : AppStrings.syncNothingPending,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionControllerProvider);
    final accounts =
        ref.watch(accountControllerProvider).valueOrNull ??
        const <AccountEntity>[];
    final categories =
        ref.watch(categoryControllerProvider).valueOrNull ??
        const <CategoryEntity>[];
    final pendingCount =
        transactionsAsync.valueOrNull
            ?.where((t) => t.syncStatus == SyncStatus.pendingSync)
            .length ??
        0;
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.transactionsTitle),
        actions: [
          if (pendingCount > 0)
            Badge.count(
              count: pendingCount,
              child: IconButton(
                tooltip: AppStrings.syncNow,
                onPressed: _syncing ? null : _syncNow,
                icon: const Icon(Icons.cloud_upload_outlined),
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.transactionForm),
        icon: const Icon(Icons.edit_note),
        label: Text(AppStrings.manualEntry),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SegmentedButton<TransactionType?>(
              segments: const [
                ButtonSegment(value: null, label: Text(AppStrings.all)),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(AppStrings.income),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(AppStrings.expense),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) =>
                  setState(() => _filter = selection.first),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (pendingCount > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: colors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(AppStrings.pendingTransactions(pendingCount)),
                  ),
                  TextButton(
                    onPressed: _syncing ? null : _syncNow,
                    child: Text(
                      _syncing ? AppStrings.syncing : AppStrings.syncNow,
                    ),
                  ),
                ],
              ),
            ),
          if (pendingCount > 0) const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.resolve(context, AppMotion.base),
              switchInCurve: AppMotion.standard,
              switchOutCurve: AppMotion.exit,
              child: transactionsAsync.when(
                loading: () => const AppSkeletonLoader(
                  key: ValueKey('transactions-loading'),
                ),
                error: (error, _) => AppErrorView(
                  key: ValueKey(error.toString()),
                  message: error.toString(),
                  onRetry: () => ref.invalidate(transactionControllerProvider),
                ),
                data: (transactions) {
                  final filtered = _filter == null
                      ? transactions
                      : transactions.where((t) => t.type == _filter).toList();
                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      key: ValueKey('empty-$_filter'),
                      onRefresh: _syncNow,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 320,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Text(
                                  AppStrings.emptyTransactions,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    key: ValueKey('list-$_filter'),
                    onRefresh: _syncNow,
                    child: _groupedList(filtered, accounts, categories),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupedList(
    List<TransactionEntity> transactions,
    List<AccountEntity> accounts,
    List<CategoryEntity> categories,
  ) {
    final groups = <String, List<TransactionEntity>>{};
    for (final transaction in transactions) {
      final label = DateFormatter.groupLabel(transaction.date);
      groups.putIfAbsent(label, () => []).add(transaction);
    }

    final children = <Widget>[];
    var itemIndex = 0;
    for (final entry in groups.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(entry.key, style: Theme.of(context).textTheme.labelSmall),
        ),
      );
      for (final transaction in entry.value) {
        final category = categories
            .where((c) => c.id == transaction.categoryId)
            .firstOrNull;
        children.add(
          AppAnimatedEntrance(
            index: itemIndex++,
            child: TransactionListItem(
              transaction: transaction,
              categoryName: category?.name,
              categoryIcon: category?.icon,
              categoryColor: category?.color,
              accountName: accounts
                  .where((a) => a.id == transaction.accountId)
                  .firstOrNull
                  ?.name,
              onTap: () =>
                  context.push(RouteNames.transactionEdit, extra: transaction),
            ),
          ),
        );
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      children: children,
    );
  }
}
