import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'core/config/supabase_config.dart';
import 'core/constants/app_strings.dart';
import 'core/network/supabase_client_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/scanner/presentation/controllers/scanner_controller.dart';
import 'features/transactions/presentation/controllers/transaction_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: ScanWalletApp()));
}

/// App shell. Watches the Android share sheet (ACTION_SEND image/*) so a
/// receipt shared from another app (gallery, WhatsApp, ...) opens the
/// scanner directly and gets OCR'd (TASKS.md 9.x). PRD.md §6.4 still
/// applies: OCR pre-fills the form, the user confirms before saving.
class ScanWalletApp extends ConsumerStatefulWidget {
  const ScanWalletApp({super.key});

  @override
  ConsumerState<ScanWalletApp> createState() => _ScanWalletAppState();
}

class _ScanWalletAppState extends ConsumerState<ScanWalletApp>
    with WidgetsBindingObserver {
  StreamSubscription<List<SharedMediaFile>>? _mediaSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Unsupported platforms (e.g. Windows desktop) throw
    // MissingPluginException — the share flow is Android-only, so a silent
    // no-op keeps the app runnable everywhere.
    try {
      _mediaSubscription = ReceiveSharingIntent.instance
          .getMediaStream()
          .listen(_handleSharedMedia, onError: (_) {});
      ReceiveSharingIntent.instance.getInitialMedia().then(
        _handleSharedMedia,
        onError: (_) {},
      );
    } catch (_) {
      // No-op: share receiving unavailable on this platform.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final client = ref.read(supabaseClientProvider);
    if (client.auth.currentSession == null) return;
    ref
        .read(transactionControllerProvider.notifier)
        .setForeground(state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mediaSubscription?.cancel();
    super.dispose();
  }

  void _handleSharedMedia(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    final path = files.first.path;
    if (path.isEmpty) return;
    // Debounce: getInitialMedia() and getMediaStream() can both fire for the
    // same cold-start intent on some devices.
    final now = DateTime.now();
    if (path == _lastSharedPath &&
        now.difference(_lastSharedAt) < const Duration(seconds: 3)) {
      return;
    }
    _lastSharedPath = path;
    _lastSharedAt = now;
    ReceiveSharingIntent.instance.reset();
    // Shares while logged out are dropped: the router would bounce the
    // user to /login anyway. They can re-share after signing in.
    final client = ref.read(supabaseClientProvider);
    if (client.auth.currentSession == null) return;
    final router = ref.read(appRouterProvider);
    // Sharing again while /scan is already on top must NOT push a second
    // /scan page — duplicate page keys crash the navigator with
    // '!keyReservation.contains(key)' (PRD: fix blank screen). Process the
    // new image through the live scanner controller instead.
    final isOnScanner =
        router.routerDelegate.currentConfiguration.uri.path ==
        RouteNames.scanner;
    if (isOnScanner) {
      ref.read(scannerControllerProvider.notifier).scanFile(path);
      return;
    }
    router.push(RouteNames.scanner, extra: path);
  }

  String? _lastSharedPath;
  DateTime _lastSharedAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
