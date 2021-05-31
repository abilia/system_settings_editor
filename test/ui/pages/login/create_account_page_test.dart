// @dart=2.9

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../mocks.dart';

void main() {
  group(
    'create account',
    () {
      final translate = Locales.language.values.first;

      setUp(() async {
        GetItInitializer()
          ..sharedPreferences =
              await MockSharedPreferences.getInstance(loggedIn: false)
          ..ticker = Ticker(
            stream: StreamController<DateTime>().stream,
            initialTime: DateTime(2021, 05, 13, 11, 29),
          )
          ..client = Fakes.client()
          ..database = MockDatabase()
          ..init();
      });

      tearDown(GetIt.I.reset);

      testWidgets('Go to create account and back', (tester) async {
        await tester.pumpApp();
        expect(find.byType(MEMOplannerLoginFooter), findsOneWidget);
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        expect(find.byType(CreateAccountPage), findsOneWidget);
        await tester.tap(find.byType(BackToLoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      });

      testWidgets('Created account name in login page', (tester) async {
        final username = 'this_is_a_user_name',
            password = 't/-/15_15_4_/>455w0|2|)';
        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        await tester.enterText_(find.byType(UsernameInput), username);
        await tester.enterText_(
            find.byKey(TestKey.createAccountPassword), password);
        await tester.enterText_(
            find.byKey(TestKey.createAccountPasswordConfirm), password);
        await tester.tap(find.byKey(TestKey.acceptPrivacyPolicy));
        await tester.tap(find.byKey(TestKey.acceptTermsOfUse));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CreateAccountButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(find.byType(CreateAccountPage), findsNothing);
        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.text(username), findsOneWidget);
      });

      testWidgets('Errors', (tester) async {
        Future _expectErrorDialog(WidgetTester tester, String errorMessage,
            {Matcher matcher = findsOneWidget}) async {
          await tester.tap(find.byType(CreateAccountButton));
          await tester.pumpAndSettle();
          expect(find.byType(ErrorDialog), findsOneWidget);
          expect(find.text(errorMessage), matcher);
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
        }

        final toShortUsername = 'ab',
            username = 'abc',
            takenUsername = 'taken',
            toShortPassword = 'abcdefg',
            password = 'abcdefgh';

        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();

        await _expectErrorDialog(tester, translate.enterUsername);

        await tester.enterText_(find.byType(UsernameInput), toShortUsername);

        await _expectErrorDialog(tester, translate.usernameToShort);

        await tester.enterText_(find.byType(UsernameInput), takenUsername);

        await _expectErrorDialog(tester, translate.enterPassword);

        await tester.enterText_(
            find.byKey(TestKey.createAccountPassword), toShortPassword);

        await _expectErrorDialog(tester, translate.passwordToShort);

        await tester.enterText_(
            find.byKey(TestKey.createAccountPassword), password);

        await _expectErrorDialog(tester, translate.confirmPassword,
            matcher: findsNWidgets(2));

        await tester.enterText_(
            find.byKey(TestKey.createAccountPasswordConfirm), toShortPassword);

        await _expectErrorDialog(tester, translate.passwordMismatch);

        await tester.enterText_(
            find.byKey(TestKey.createAccountPasswordConfirm), password);

        await _expectErrorDialog(tester, translate.confirmTermsOfUse);

        await tester.tap(find.byKey(TestKey.acceptTermsOfUse));
        await tester.pumpAndSettle();

        await _expectErrorDialog(tester, translate.confirmPrivacyPolicy);

        await tester.tap(find.byKey(TestKey.acceptPrivacyPolicy));
        await tester.pumpAndSettle();

        await _expectErrorDialog(tester, translate.usernameTaken);

        await tester.enterText_(find.byType(UsernameInput), username);

        await tester.tap(find.byType(CreateAccountButton));
        await tester.pumpAndSettle();

        expect(find.text(translate.accountCreatedHeading), findsOneWidget);
        expect(find.text(translate.accountCreatedBody), findsOneWidget);

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(find.byType(CreateAccountPage), findsNothing);
        expect(find.byType(LoginPage), findsOneWidget);
      });

      testWidgets('Open terms of use', (tester) async {
        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        expect(find.tapTextSpan(translate.termsOfUse), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(WebViewDialog), findsOneWidget);
        final openedUrl =
            tester.widget<WebView>(find.byType(WebView)).initialUrl;
        expect(openedUrl, CreateAccountPage.termsOfUseUrl);
      });

      testWidgets('Open privacy policy', (tester) async {
        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        expect(find.tapTextSpan(translate.privacyPolicy), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(WebViewDialog), findsOneWidget);
        final openedUrl =
            tester.widget<WebView>(find.byType(WebView)).initialUrl;
        expect(openedUrl, CreateAccountPage.privacyPolicyUrl);
      });
    },
    skip: !Config.isMP,
  );
}
