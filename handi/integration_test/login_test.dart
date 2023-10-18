import 'package:flutter_test/flutter_test.dart';
import 'package:handi/ui/components/backend_banner.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login/login_page.dart';
import 'package:patrol/patrol.dart';
import 'package:repository_base/end_point.dart';
import 'package:ui/components/action_button/action_button.dart';

import 'test_helpers.dart';

void main() {
  const username = 'handi_integration_test_account';
  const password = 'password1234';

  Future<void> testLogin({
    required String environment,
    required bool expectBackendBanner,
    required PatrolIntegrationTester patrol,
  }) async {
    await pumpAndSettleHandiApp(patrol);

    await patrol.enterText(find.byTooltip('Username'), username);
    await patrol.enterText(find.byTooltip('Password'), password);
    await patrol.tester.testTextInput.receiveAction(TextInputAction.done);
    await patrol.tester.longPress(find.byType(LogoWithChangeServer));
    await patrol.tap(find.text(environment));
    await patrol.tester.tapAt(const Offset(10, 10));

    expect(find.byType(BackendBanner),
        expectBackendBanner ? findsOneWidget : findsNothing);

    await patrol.tap(find.byType(ActionButtonPrimary));

    await patrol.native.grantPermissionWhenInUse();
    await patrol.pumpAndSettle();
    expect(find.byType(LoggedInPage), findsOneWidget);
    await patrol.tap(find.text('Log out'));
    expect(find.byType(LoginPage), findsOneWidget);
  }

  group('Account with license', () {
    patrolTest('TEST', nativeAutomation: true, (patrol) async {
      await testLogin(
        environment: testName,
        expectBackendBanner: true,
        patrol: patrol,
      );
    });

    patrolTest('STAGING', nativeAutomation: true, (patrol) async {
      await testLogin(
        environment: stagingName,
        expectBackendBanner: true,
        patrol: patrol,
      );
    });

    patrolTest('PROD', nativeAutomation: true, (patrol) async {
      await testLogin(
        environment: prodName,
        expectBackendBanner: false,
        patrol: patrol,
      );
    });
  });
}
