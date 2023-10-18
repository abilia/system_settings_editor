import 'package:flutter_test/flutter_test.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login_page.dart';
import 'package:patrol/patrol.dart';
import 'package:repository_base/end_point.dart';
import 'package:ui/components/action_button/action_button.dart';

import 'test_helpers.dart';

void main() {
  const username = 'handi_integration_test_account';
  const password = 'password1234';

  Future<void> testLogin({
    required String environment,
    required PatrolIntegrationTester patrol,
  }) async {
    await pumpAndSettleHandiApp(patrol);

    await patrol.enterText(find.byTooltip('Username'), username);
    await patrol.enterText(find.byTooltip('Password'), password);
    await patrol.tester.testTextInput.receiveAction(TextInputAction.done);
    await patrol.tap(find.text(environment));
    await patrol.tap(find.byType(ActionButtonPrimary));

    await patrol.native.grantPermissionWhenInUse();
    await patrol.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsOneWidget);
    await patrol.tap(find.text('Log out'));
    expect(find.byType(LoginPage), findsOneWidget);
  }

  group('Accounts with license', () {
    patrolTest('T1', nativeAutomation: true, (patrol) async {
      await testLogin(environment: testName, patrol: patrol);
    });

    patrolTest('Staging', nativeAutomation: true, (patrol) async {
      await testLogin(environment: stagingName, patrol: patrol);
    });

    patrolTest('Production', nativeAutomation: true, (patrol) async {
      await testLogin(environment: prodName, patrol: patrol);
    });
  });
}
