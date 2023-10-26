import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handi/l10n/generated/l10n.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login/login_page.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:patrol/patrol.dart';
import 'package:repository_base/end_point.dart';
import '../test/extensions/finder_extensions.dart';

import 'test_helpers.dart';

void main() {
  late final Lt translate;
  const username = 'handi_integration_test_account';
  const usernameExpiredLicense = 'handi_integration_test_account2';
  const usernameSupportPerson =
      'handi_integration_support_test_account@test.se';
  const password = 'password1234';

  setUpAll(() async {
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);
  });

  Future<void> changeEnvironment(
    PatrolIntegrationTester patrol, {
    required String environment,
  }) async {
    await patrol.tester.longPress(find.byType(LogoWithChangeServer));
    await patrol.tap(find.text(environment));
    await patrol.tester.tapAt(const Offset(10, 10));
    await patrol.tester.pumpAndSettle();
  }

  Future<void> testLogin(
    PatrolIntegrationTester patrol, {
    required String environment,
  }) async {
    await changeEnvironment(patrol, environment: environment);

    // Enter username and password and press enter on keyboard
    await patrol.enterText(find.usernameField, username);
    await patrol.enterText(find.passwordField, password);
    await patrol.tester.testTextInput.receiveAction(TextInputAction.done);

    // CircularProgressIndicator is shown while waiting for response
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await patrol.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await patrol.pumpAndSettle();

    // Grant notification permission if dialog is shown
    if (await patrol.native.isPermissionDialogVisible()) {
      await patrol.native.grantPermissionWhenInUse();
      await patrol.pumpAndSettle();
    }

    expect(find.byType(LoggedInPage), findsOneWidget);
    await patrol.tap(find.text(translate.logOut));
    expect(find.byType(LoginPage), findsOneWidget);
  }

  patrolTest('Login TEST, STAGING and PROD environments',
      nativeAutomation: true, (patrol) async {
    await pumpAndSettleHandiApp(patrol);
    await testLogin(patrol, environment: testName);
    await testLogin(patrol, environment: stagingName);
    await testLogin(patrol, environment: prodName);
  });

  /// Error messages for invalid credentials, too many attempts, unsupported user type, expired license and no connection.
  /// Error message for no license can't be tested as users gets a 2 month trial license upon logging in.
  patrolTest('Error messages', nativeAutomation: true, (patrol) async {
    await pumpAndSettleHandiApp(patrol);
    await changeEnvironment(patrol, environment: stagingName);

    // Invalid credentials
    await patrol.enterText(find.usernameField, username);
    await patrol.enterText(find.passwordField, 'wrong_password');
    await patrol.tester.testTextInput.receiveAction(TextInputAction.done);
    await patrol.pumpAndSettle();

    expect(find.byIcon(Symbols.error), findsOneWidget);
    expect(find.text(translate.verifyCredentials), findsOneWidget);

    // Too many attempts
    await patrol.tap(find.loginButton);

    expect(find.byIcon(Symbols.lightbulb), findsOneWidget);
    expect(find.text(translate.tooManyAttempts), findsOneWidget);

    // Unsupported user type
    await patrol.enterText(find.usernameField, usernameSupportPerson);
    await patrol.enterText(find.passwordField, password);
    await patrol.tester.testTextInput.receiveAction(TextInputAction.done);
    await patrol.pumpAndSettle();

    expect(find.byIcon(Symbols.error), findsOneWidget);
    expect(find.text(translate.unsupportedUserType), findsOneWidget);

    // Expired license
    await patrol.enterText(find.usernameField, usernameExpiredLicense);
    await patrol.enterText(find.passwordField, password);
    await patrol.tester.testTextInput.receiveAction(TextInputAction.done);
    await patrol.pumpAndSettle();

    expect(find.byIcon(Symbols.error), findsOneWidget);
    expect(find.text(translate.noHandiLicence), findsOneWidget);

    // No connection
    await patrol.native.disableWifi();
    await patrol.tap(find.loginButton);

    expect(find.byIcon(Symbols.error), findsOneWidget);
    expect(find.text(translate.connectToInternet), findsOneWidget);

    await patrol.native.enableWifi();
  });
}
