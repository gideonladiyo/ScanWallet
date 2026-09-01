import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scan_wallet/core/error/exceptions.dart';
import 'package:scan_wallet/core/error/failure_mapper.dart';
import 'package:scan_wallet/core/error/failures.dart';

void main() {
  test('maps typed transport errors to NetworkFailure', () {
    expect(
      mapExceptionToFailure(const SocketException('offline')),
      isA<NetworkFailure>(),
    );
    expect(
      mapExceptionToFailure(TimeoutException('timeout')),
      isA<NetworkFailure>(),
    );
  });

  test('maps missing auth session to AuthFailure', () {
    final failure = mapExceptionToFailure(
      const AuthSessionException('session expired'),
    );

    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'session expired');
  });
}
