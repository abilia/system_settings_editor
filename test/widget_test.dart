import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/main.dart';

Widget makeTestableWidget({Widget child}) {
  return MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: child,
    ),
  );
}

void main() {
  testWidgets("Widget", (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(child: MyApp()));
    await tester.pumpAndSettle();
    var findByText = find.byType(Text);
    expect(findByText.evaluate().isEmpty, false);
    expect(find.text('Password'), findsOneWidget);
  });
}
