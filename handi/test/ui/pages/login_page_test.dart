import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/l10n/all.dart';
import 'package:handi/main.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login_page.dart';
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
    final loginButtonFinder =
        find.widgetWithText(ActionButton, translate.signIn);
    final loginButtonFinder =
        find.widgetWithText(ActionButton, translate.signIn);
    expect(loginButtonFinder, findsOneWidget);
    expect(
      tester.widget<ActionButton>(loginButtonFinder).onPressed,
      tester.widget<ActionButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.enterText(find.byTooltip('Username'), 'uname');
    await tester.enterText(find.byTooltip('Password'), 'pword');
    await tester.pumpAndSettle();
    expect(
      tester.widget<ActionButton>(loginButtonFinder).onPressed,
      tester.widget<ActionButton>(loginButtonFinder).onPressed,
      isNotNull,
    );
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsOneWidget);
  });
}
