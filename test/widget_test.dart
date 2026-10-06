import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aperture/app.dart';

void main() {
  testWidgets('shell shows three empty surfaces in Norwegian', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ApertureApp()));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Ingen mappe er gitt tilgang ennå. Snitt 2 legger til mappetilgang.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Nett'));
    await tester.pumpAndSettle();
    expect(
      find.text('Ingen fane er åpen. Snitt 4 legger til nettvisning.'),
      findsOneWidget,
    );

    await tester.tap(find.text('KI'));
    await tester.pumpAndSettle();
    expect(
      find.text('KI er av til et endepunkt er satt. Snitt 5.'),
      findsOneWidget,
    );
  });
}
