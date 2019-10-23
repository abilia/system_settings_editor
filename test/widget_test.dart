import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/main.dart';

void main() {
  testWidgets("Widget", (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    var findByText = find.byType(Text);
    expect(findByText.evaluate().isEmpty, false);
    expect(find.text('Password'), findsOneWidget);
  });
}
