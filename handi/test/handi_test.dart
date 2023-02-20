import 'package:flutter_test/flutter_test.dart';

import 'package:handi/main.dart';

void main() {
  testWidgets('Text "Handi!" is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const HandiApp());

    expect(find.text('Handi!'), findsOneWidget);
  });
}
