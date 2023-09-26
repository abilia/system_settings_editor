import 'package:carymessenger/l10n/all.dart';
import 'package:carymessenger/main.dart';
import 'package:carymessenger/ui/pages/logged_in_page.dart';
import 'package:carymessenger/ui/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull_fakes/all.dart';

import '../../fakes/fake_getit.dart';

void main() {
  late final Lt translate;

  setUp(() async {
    setupPermissions();
    initGetItFakes();
  });

  setUpAll(() async {
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('can login', (tester) async {
    await tester.pumpWidget(const CaryMobileApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    final loginButtonFinder = find.widgetWithText(TextButton, 'Sign in');
    expect(loginButtonFinder, findsOneWidget);
    expect(
      tester.widget<TextButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.enterText(find.byTooltip(translate.username_email), 'uname');
    await tester.enterText(find.byTooltip('Password'), 'pword');
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextButton>(loginButtonFinder).onPressed,
      isNotNull,
    );
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsOneWidget);
  });
}
