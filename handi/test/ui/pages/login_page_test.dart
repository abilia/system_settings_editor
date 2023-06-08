import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/main.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login_page.dart';
import 'package:ui/buttons/link_button.dart';

import '../../fakes/fake_getit.dart';

void main() {
  setUp(() => initGetItFakes());
  tearDown(() => GetIt.I.reset());
  testWidgets('shows', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('can login', (tester) async {
    await tester.pumpWidget(const HandiApp());
    await tester.pumpAndSettle();
    final loginButtonFinder = find.widgetWithText(LinkButton, 'Sign in');
    expect(
      tester.widget<LinkButton>(loginButtonFinder).onPressed,
      isNull,
    );
    await tester.enterText(find.byTooltip('Username'), 'uname');
    await tester.enterText(find.byTooltip('Password'), 'pword');
    await tester.pumpAndSettle();
    expect(
      tester.widget<LinkButton>(loginButtonFinder).onPressed,
      isNotNull,
    );
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsOneWidget);
  });
}
