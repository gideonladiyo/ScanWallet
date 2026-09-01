import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_animated_entrance.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_skeleton_loader.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/transaction_list_preview.dart';

/// Dashboard with balance summary, period filter, expense breakdown and
/// recent transactions (TASKS.md 7C.2).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _syncPending(
    BuildContext context,
    WidgetRef ref, {
    bool showFeedback = true,
  }) async {
    final result = await ref
        .read(transactionControllerProvider.notifier)
        .syncPending();
    if (!context.mounted || !showFeedback) return;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardControllerProvider);
    final period = ref.watch(dashboardPeriodProvider);
    final transactionsAsync = ref.watch(transactionControllerProvider);
    final hasTransactions = transactionsAsync.valueOrNull?.isNotEmpty ?? false;
    final pendingCount =
        transactionsAsync.valueOrNull
            ?.where((t) => t.syncStatus == SyncStatus.pendingSync)
            .length ??
        0;
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          if (pendingCount > 0)
            Badge.count(
              count: pendingCount,
              child: IconButton(
                tooltip: AppStrings.syncNow,
                icon: const Icon(Icons.cloud_upload_outlined),
                onPressed: () => _syncPending(context, ref),
              ),
            ),
          IconButton(
            tooltip: AppStrings.logoutButton,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _syncPending(context, ref, showFeedback: false);
          ref.invalidate(dashboardControllerProvider);
          ref.invalidate(transactionControllerProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (pendingCount > 0) ...[
              Container(
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
                      onPressed: () => _syncPending(context, ref),
                      child: Text(AppStrings.syncNow),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            SegmentedButton<PeriodFilter>(
              segments: const [
                ButtonSegment(
                  value: PeriodFilter.week,
                  label: Text(AppStrings.periodWeek),
                ),
                ButtonSegment(
                  value: PeriodFilter.month,
                  label: Text(AppStrings.periodMonth),
                ),
                ButtonSegment(
                  value: PeriodFilter.year,
                  label: Text(AppStrings.periodYear),
                ),
              ],
              selected: {period},
              onSelectionChanged: (selection) => ref
                  .read(dashboardPeriodProvider.notifier)
                  .set(selection.first),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: AppMotion.resolve(context, AppMotion.base),
              switchInCurve: AppMotion.standard,
              switchOutCurve: AppMotion.exit,
              child: summaryAsync.when(
                loading: () => const SizedBox(
                  key: ValueKey('dashboard-loading'),
                  height: 220,
                  child: AppSkeletonLoader(
                    itemCount: 1,
                    itemHeight: 120,
                    padding: EdgeInsets.zero,
                  ),
                ),
                error: (error, _) => AppErrorView(
                  key: ValueKey(error.toString()),
                  message: error.toString(),
                  onRetry: () => ref.invalidate(dashboardControllerProvider),
                ),
                data: (summary) => AppAnimatedEntrance(
                  key: ValueKey(period),
                  child: BalanceSummaryCard(summary: summary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (!hasTransactions) ...[
              const SizedBox(height: AppSpacing.lg),
              const _EmptyTransactionIllustration(),
              const SizedBox(height: AppSpacing.md),
              AppAnimatedEntrance(
                index: 1,
                child: Text(
                  AppStrings.scanFirstTransaction,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppAnimatedEntrance(
                index: 2,
                child: AppButton.primary(
                  label: AppStrings.scanTitle,
                  leadingIcon: Icons.document_scanner,
                  expanded: true,
                  onPressed: () => context.push(RouteNames.scanner),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppAnimatedEntrance(
                index: 3,
                child: AppButton.secondary(
                  label: AppStrings.manualEntry,
                  leadingIcon: Icons.edit_note,
                  expanded: true,
                  onPressed: () => context.push(RouteNames.transactionForm),
                ),
              ),
            ] else ...[
              Text(
                AppStrings.expenseBreakdown,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: summaryAsync.maybeWhen(
                    data: (summary) =>
                        CategoryBreakdownChart(breakdown: summary.breakdown),
                    orElse: () => const AppLoadingIndicator(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.recentTransactions,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => context.go(RouteNames.transactions),
                    child: Text(AppStrings.viewAll),
                  ),
                ],
              ),
              Card(child: TransactionListPreview(limit: 5)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactionIllustration extends StatefulWidget {
  const _EmptyTransactionIllustration();

  @override
  State<_EmptyTransactionIllustration> createState() =>
      _EmptyTransactionIllustrationState();
}

class _EmptyTransactionIllustrationState
    extends State<_EmptyTransactionIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.float);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimatedEntrance(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -4 + (_controller.value * 8)),
          child: child,
        ),
        child: Icon(
          Icons.account_balance_wallet_outlined,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
