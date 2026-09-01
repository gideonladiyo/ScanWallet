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
import '../controllers/account_controller.dart';
import '../widgets/account_card.dart';

class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.accountsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.accountForm),
        icon: const Icon(Icons.add),
        label: Text(AppStrings.addAccount),
      ),
      body: AnimatedSwitcher(
        duration: AppMotion.resolve(context, AppMotion.base),
        child: accountsAsync.when(
          loading: () =>
              const AppSkeletonLoader(key: ValueKey('accounts-loading')),
          error: (error, _) => AppErrorView(
            key: ValueKey(error.toString()),
            message: error.toString(),
            onRetry: () => ref.invalidate(accountControllerProvider),
          ),
          data: (accounts) => accounts.isEmpty
              ? Center(
                  key: const ValueKey('accounts-empty'),
                  child: AppAnimatedEntrance(
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : ListView.separated(
                  key: const ValueKey('accounts-data'),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: accounts.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => AppAnimatedEntrance(
                    index: index,
                    child: AccountCard(
                      account: accounts[index],
                      onTap: () => context.push(
                        RouteNames.accountEdit,
                        extra: accounts[index],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
