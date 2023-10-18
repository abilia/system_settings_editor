import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/l10n/all.dart';
import 'package:handi/main.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login/login_page.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:seagull_fakes/all.dart';
import 'package:ui/components/buttons/buttons.dart';

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

  testWidgets('shows', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('can login', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    final loginButtonFinder = find.widgetWithText(
      SeagullActionButton,
      translate.signIn,
    );
    expect(loginButtonFinder, findsOneWidget);
    expect(
      tester.widget<SeagullActionButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.enterText(
        find.byTooltip('Username'), FakeListenableClient.username);
    await tester.enterText(find.byTooltip('Password'), 'pword');
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeagullActionButton>(loginButtonFinder).onPressed,
      isNotNull,
    );
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsOneWidget);
  });

  testWidgets('can not login without password', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    final loginButtonFinder = find.widgetWithText(
      SeagullActionButton,
      translate.signIn,
    );
    expect(loginButtonFinder, findsOneWidget);
    expect(
      tester.widget<SeagullActionButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.enterText(
        find.byTooltip('Username'), FakeListenableClient.username);
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeagullActionButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsNothing);
  });

  testWidgets('wrong password shows error message', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    final loginButtonFinder = find.widgetWithText(
      SeagullActionButton,
      translate.signIn,
    );
    await tester.enterText(
        find.byTooltip('Username'), FakeListenableClient.username);
    await tester.enterText(
        find.byTooltip('Password'), FakeListenableClient.incorrectPassword);
    await tester.pumpAndSettle();
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byIcon(Symbols.error), findsOneWidget);
    expect(find.byType(LoggedInPage), findsNothing);
  });

  testWidgets('can not login without password', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    final loginButtonFinder = find.widgetWithText(
      SeagullActionButton,
      translate.signIn,
    );
    expect(loginButtonFinder, findsOneWidget);
    expect(
      tester.widget<SeagullActionButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.enterText(
        find.byTooltip('Username'), FakeListenableClient.username);
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeagullActionButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsNothing);
  });

  testWidgets('wrong password shows error message', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    final loginButtonFinder = find.widgetWithText(
      SeagullActionButton,
      translate.signIn,
    );
    await tester.enterText(
        find.byTooltip('Username'), FakeListenableClient.username);
    await tester.enterText(
        find.byTooltip('Password'), FakeListenableClient.incorrectPassword);
    await tester.pumpAndSettle();
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byIcon(Symbols.error), findsOneWidget);
    expect(find.byType(LoggedInPage), findsNothing);
  });

  testWidgets('can not login without password', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    final loginButtonFinder = find.widgetWithText(
      SeagullActionButton,
      translate.signIn,
    );
    expect(loginButtonFinder, findsOneWidget);
    expect(
      tester.widget<SeagullActionButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.enterText(
        find.byTooltip('Username'), FakeListenableClient.username);
    await tester.pumpAndSettle();
    expect(
      tester.widget<SeagullActionButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsNothing);
  });

  testWidgets('wrong password shows error message', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    final loginButtonFinder = find.widgetWithText(
      SeagullActionButton,
      translate.signIn,
    );
    await tester.enterText(
        find.byTooltip('Username'), FakeListenableClient.username);
    await tester.enterText(
        find.byTooltip('Password'), FakeListenableClient.incorrectPassword);
    await tester.pumpAndSettle();
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byIcon(Symbols.error), findsOneWidget);
    expect(find.byType(LoggedInPage), findsNothing);
  });
}
