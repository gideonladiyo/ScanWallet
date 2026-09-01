import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_animated_entrance.dart';
import '../../../../core/widgets/app_skeleton_loader.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../../../transactions/presentation/widgets/transaction_list_item.dart';

/// Latest transactions shown on the dashboard (TASKS.md 7C.5).
class TransactionListPreview extends ConsumerWidget {
  const TransactionListPreview({super.key, this.limit = 5});

  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionControllerProvider);
    final accounts =
        ref.watch(accountControllerProvider).valueOrNull ??
        const <AccountEntity>[];
    final categories =
        ref.watch(categoryControllerProvider).valueOrNull ??
        const <CategoryEntity>[];

    return transactionsAsync.when(
      loading: () => const SizedBox(
        height: 240,
        child: AppSkeletonLoader(itemCount: 3, padding: EdgeInsets.zero),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          error.toString(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              AppStrings.emptyTransactions,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return Column(
          children: transactions.take(limit).indexed.map((entry) {
            final (index, transaction) = entry;
            final category = categories
                .where((c) => c.id == transaction.categoryId)
                .firstOrNull;
            return AppAnimatedEntrance(
              index: index,
              child: TransactionListItem(
                transaction: transaction,
                categoryName: category?.name,
                categoryIcon: category?.icon,
                categoryColor: category?.color,
                accountName: accounts
                    .where((a) => a.id == transaction.accountId)
                    .firstOrNull
                    ?.name,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
