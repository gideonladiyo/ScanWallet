import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/domain/entities/account_entity.dart';
import '../../features/accounts/presentation/screens/account_form_screen.dart';
import '../../features/accounts/presentation/screens/account_list_screen.dart';
import '../../features/categories/domain/entities/category_entity.dart';
import '../../features/categories/presentation/screens/category_form_screen.dart';
import '../../features/categories/presentation/screens/category_list_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/scanner/presentation/screens/scan_camera_screen.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../../features/transactions/presentation/screens/transaction_form_screen.dart';
import '../../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../network/supabase_client_provider.dart';
import '../theme/app_motion.dart';
import '../widgets/home_shell.dart';

/// Named routes used across the app.
class RouteNames {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/';
  static const String transactions = '/transactions';
  static const String transactionForm = '/transactions/new';
  static const String transactionEdit = '/transactions/edit';
  static const String accounts = '/accounts';
  static const String accountForm = '/accounts/new';
  static const String accountEdit = '/accounts/edit';
  static const String categories = '/categories';
  static const String categoryForm = '/categories/new';
  static const String categoryEdit = '/categories/edit';
  static const String scanner = '/scan';
}

/// Adapts a Stream into a Listenable for GoRouter's refreshListenable.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

CustomTransitionPage<void> _appPage(
  GoRouterState state,
  Widget child, {
  bool modal = false,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.slow,
    reverseTransitionDuration: AppMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.standard,
        reverseCurve: AppMotion.exit,
      );
      final offset = modal ? const Offset(0, 0.08) : const Offset(0.06, 0);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: offset, end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// GoRouter configuration with auth-state redirect (TASKS.md 1G.1, 8.2).
final appRouterProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);

  return GoRouter(
    refreshListenable: GoRouterRefreshStream(client.auth.onAuthStateChange),
    redirect: (context, state) {
      final loggedIn = client.auth.currentSession != null;
      final onAuthRoute =
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register;

      if (!loggedIn && !onAuthRoute) return RouteNames.login;
      if (loggedIn && onAuthRoute) return RouteNames.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) => _appPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (context, state) =>
            _appPage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: RouteNames.scanner,
        pageBuilder: (context, state) => _appPage(
          state,
          ScanCameraScreen(initialImagePath: state.extra as String?),
          modal: true,
        ),
      ),
      GoRoute(
        path: RouteNames.transactionForm,
        pageBuilder: (context, state) => _appPage(
          state,
          TransactionFormScreen(
            initial: state.extra as TransactionEntity?,
          ),
          modal: true,
        ),
      ),
      GoRoute(
        path: RouteNames.transactionEdit,
        pageBuilder: (context, state) => _appPage(
          state,
          TransactionFormScreen(
            initial: state.extra as TransactionEntity?,
          ),
          modal: true,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                pageBuilder: (context, state) =>
                    _appPage(state, const DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.transactions,
                pageBuilder: (context, state) =>
                    _appPage(state, const TransactionListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.accounts,
                pageBuilder: (context, state) =>
                    _appPage(state, const AccountListScreen()),
                routes: [
                  GoRoute(
                    path: 'new',
                    pageBuilder: (context, state) => _appPage(
                      state,
                      AccountFormScreen(account: state.extra as AccountEntity?),
                      modal: true,
                    ),
                  ),
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => _appPage(
                      state,
                      AccountFormScreen(account: state.extra as AccountEntity?),
                      modal: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.categories,
                pageBuilder: (context, state) =>
                    _appPage(state, const CategoryListScreen()),
                routes: [
                  GoRoute(
                    path: 'new',
                    pageBuilder: (context, state) => _appPage(
                      state,
                      CategoryFormScreen(
                        category: state.extra as CategoryEntity?,
                      ),
                      modal: true,
                    ),
                  ),
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => _appPage(
                      state,
                      CategoryFormScreen(
                        category: state.extra as CategoryEntity?,
                      ),
                      modal: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
