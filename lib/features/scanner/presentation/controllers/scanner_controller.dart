import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/result.dart';
import '../../scanner_providers.dart';
import '../../domain/entities/scan_result_entity.dart';

/// Scan flow state: idle → processing → parsed result (or error).
class ScannerController extends AsyncNotifier<ScanResultEntity?> {
  @override
  FutureOr<ScanResultEntity?> build() async => null;

  /// [fromCamera] picks the image source; user cancellation leaves state
  /// untouched.
  Future<void> scan({required bool fromCamera}) async {
    final picked = await ImagePicker().pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    await scanFile(picked.path);
  }

  /// Scans an already-available image file (e.g. a receipt shared from
  /// another app via the Android share sheet) without opening the picker.
  Future<void> scanFile(String path) async {
    state = const AsyncLoading();
    final result = await ref.read(scanReceiptUsecaseProvider).call(path);
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      AsyncData.new,
    );
  }

  void clear() {
    state = const AsyncData(null);
  }
}

final scannerControllerProvider =
    AsyncNotifierProvider<ScannerController, ScanResultEntity?>(
      ScannerController.new,
    );
