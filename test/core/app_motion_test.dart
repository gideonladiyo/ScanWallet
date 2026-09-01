import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan_wallet/core/theme/app_motion.dart';

void main() {
  testWidgets('resolve removes motion when accessibility disables animations', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (builderContext) {
            context = builderContext;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(AppMotion.resolve(context, AppMotion.base), Duration.zero);
  });

  test('stagger delay is capped for long lists', () {
    expect(AppMotion.stagger(100), AppMotion.staggerStep * 12);
  });
}
