import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../controllers/scanner_controller.dart';
import '../widgets/ocr_preview_bottom_sheet.dart';
import '../widgets/scanning_overlay.dart';

/// Scan entry screen: camera or gallery source (TASKS.md 6C.2, PRD.md §4.2).
/// [initialImagePath] comes from the Android share sheet — the image is
/// scanned immediately without opening the picker.
class ScanCameraScreen extends ConsumerStatefulWidget {
  const ScanCameraScreen({super.key, this.initialImagePath});

  final String? initialImagePath;

  @override
  ConsumerState<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends ConsumerState<ScanCameraScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: AppMotion.float,
    );
    // Show the OCR preview as soon as a result lands.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(scannerControllerProvider, (previous, next) {
        next.whenData((result) {
          if (result != null && mounted) {
            _showPreview(result);
          }
        });
      });
      final sharedPath = widget.initialImagePath;
      if (sharedPath != null && sharedPath.isNotEmpty) {
        ref.read(scannerControllerProvider.notifier).scanFile(sharedPath);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _idleController.stop();
      _idleController.value = 0.5;
    } else if (!_idleController.isAnimating) {
      _idleController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  Future<void> _showPreview(ScanResultEntity result) async {
    final controller = ref.read(scannerControllerProvider.notifier);
    final draft = await showModalBottomSheet<TransactionEntity>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => OcrPreviewBottomSheet(result: result),
    );
    controller.clear();
    if (!mounted || draft == null) return;
    await context.push(RouteNames.transactionForm, extra: draft);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final scanAsync = ref.watch(scannerControllerProvider);
    final isProcessing = scanAsync.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.scanTitle)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedBuilder(
                  animation: _idleController,
                  builder: (context, child) => Opacity(
                    opacity: 0.4 + (_idleController.value * 0.15),
                    child: child,
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    size: 96,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton.primary(
                  label: AppStrings.scanFromCamera,
                  leadingIcon: Icons.photo_camera,
                  expanded: true,
                  onPressed: isProcessing
                      ? null
                      : () => ref
                            .read(scannerControllerProvider.notifier)
                            .scan(fromCamera: true),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.secondary(
                  label: AppStrings.scanFromGallery,
                  leadingIcon: Icons.photo_library,
                  expanded: true,
                  onPressed: isProcessing
                      ? null
                      : () => ref
                            .read(scannerControllerProvider.notifier)
                            .scan(fromCamera: false),
                ),
              ],
            ),
          ),
          if (isProcessing) const ScanningOverlay(),
        ],
      ),
    );
  }
}
