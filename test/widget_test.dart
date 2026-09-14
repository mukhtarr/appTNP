import 'package:app_tnp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders auth flow and dashboard shell', (tester) async {
    await tester.pumpWidget(PlacementPortalApp(controller: AppController()));

    expect(find.text('TNP Cell Portal'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Departments'), findsOneWidget);
    expect(find.text('Jobs & Internships'), findsNothing);

    await tester.tap(find.byIcon(Icons.work_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Jobs & Internships'), findsOneWidget);
  });
}
