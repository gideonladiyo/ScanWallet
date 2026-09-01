import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/app_animated_entrance.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_skeleton_loader.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../controllers/category_controller.dart';
import '../widgets/category_chip.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.categoryForm),
        icon: const Icon(Icons.add),
        label: Text(AppStrings.addCategory),
      ),
      body: AnimatedSwitcher(
        duration: AppMotion.resolve(context, AppMotion.base),
        child: categoriesAsync.when(
          loading: () =>
              const AppSkeletonLoader(key: ValueKey('categories-loading')),
          error: (error, _) => AppErrorView(
            key: ValueKey(error.toString()),
            message: error.toString(),
            onRetry: () => ref.invalidate(categoryControllerProvider),
          ),
          data: (categories) {
            final expense = categories
                .where((c) => c.transactionType == TransactionType.expense)
                .toList();
            final income = categories
                .where((c) => c.transactionType == TransactionType.income)
                .toList();

            if (categories.isEmpty) {
              return Center(
                key: const ValueKey('categories-empty'),
                child: AppAnimatedEntrance(
                  child: Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }

            return ListView(
              key: const ValueKey('categories-data'),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _section(context, AppStrings.expense, expense),
                const SizedBox(height: AppSpacing.lg),
                _section(context, AppStrings.income, income),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<CategoryEntity> categories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories.indexed
              .map(
                (entry) => AppAnimatedEntrance(
                  index: entry.$1,
                  child: CategoryChip(
                    category: entry.$2,
                    onTap: () =>
                        context.push(RouteNames.categoryEdit, extra: entry.$2),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
