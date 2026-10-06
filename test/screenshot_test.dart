import 'package:aperture/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('files surface', (tester) async {
    await _pump(tester);
    await expectLater(
      find.byType(ApertureApp),
      matchesGoldenFile('goldens/files.png'),
    );
  });

  testWidgets('browse surface', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Nett'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ApertureApp),
      matchesGoldenFile('goldens/browse.png'),
    );
  });

  testWidgets('ai surface', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('KI'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ApertureApp),
      matchesGoldenFile('goldens/ai.png'),
    );
  });
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(const ProviderScope(child: ApertureApp()));
  await tester.pumpAndSettle();
}
