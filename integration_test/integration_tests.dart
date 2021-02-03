import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seagull/main.dart' as app;
import 'package:seagull/ui/all.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  void login(WidgetTester tester) async {
    await tester.tap(find.byKey(TestKey.userNameInput));
    await tester.pumpAndSettle();
    await tester.showKeyboard(find.byKey(TestKey.input));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(TestKey.input), 'tobias.junsten@abilia.se');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.okDialog));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(TestKey.passwordInput));
    await tester.pumpAndSettle();
    await tester.showKeyboard(find.byKey(TestKey.input));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.input), 'password!');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.okDialog));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CancelButton));
    await tester.pumpAndSettle();
  }

  void createActivity(WidgetTester tester) async {
    await tester.tap(find.byKey(TestKey.addActivity));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NameInput));
    await tester.pumpAndSettle();

    await tester.showKeyboard(find.byKey(TestKey.input));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.input), 'Auto activity');
    await tester.tap(find.byKey(TestKey.okDialog));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TimeIntervallPicker));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(TestKey.startTimeInput));
    await tester.pumpAndSettle();
    await tester.showKeyboard(find.byKey(TestKey.startTimeInput));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.startTimeInput), '1111');
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(TestKey.finishEditActivityButton));
    await tester.pumpAndSettle();
  }

  testWidgets('Login and create activity', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();
    await login(tester);
    await createActivity(tester);

    await sleep(
        Duration(seconds: 5)); // Just to see final result before closing
  });
}
