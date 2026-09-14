import 'package:app_tnp/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders login screen on startup', (tester) async {
    await tester.pumpWidget(const TnpApp());

    expect(find.text('Login / Registration'), findsOneWidget);
    expect(find.textContaining('Sample credentials'), findsOneWidget);
  });
}
