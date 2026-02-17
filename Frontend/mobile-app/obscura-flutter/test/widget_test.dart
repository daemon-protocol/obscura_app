import 'package:flutter_test/flutter_test.dart';

import 'package:obscura_vault/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ObscuraApp());

    // Verify that the home screen loads
    expect(find.text('OBSCURA'), findsOneWidget);
  });
}
