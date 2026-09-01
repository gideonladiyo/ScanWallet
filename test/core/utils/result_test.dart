import 'package:flutter_test/flutter_test.dart';
import 'package:scan_wallet/core/error/failures.dart';
import 'package:scan_wallet/core/utils/result.dart';

void main() {
  group('Result', () {
    test('fold routes success', () {
      const Result<int> result = Success(42);
      final value = result.fold<int>((failure) => -1, (data) => data);
      expect(value, 42);
    });

    test('fold routes failure with typed AppFailure', () {
      const Result<int> result = Failure(NetworkFailure());
      final outcome = result.fold<String>(
        (failure) => failure is NetworkFailure ? 'offline' : failure.message,
        (_) => 'online',
      );
      expect(outcome, 'offline');
    });
  });
}
