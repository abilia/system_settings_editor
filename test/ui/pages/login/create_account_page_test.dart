import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/tap_link.dart';

void main() {
  group(
    'create account',
    () {
      final translate = Locales.language.values.first;

      setUp(() async {
        GetItInitializer()
          ..sharedPreferences =
              await FakeSharedPreferences.getInstance(loggedIn: false)
          ..ticker = Ticker.fake(initialTime: DateTime(2021, 05, 13, 11, 29))
          ..client = Fakes.client()
          ..database = FakeDatabase()
          ..deviceDb = FakeDeviceDb()
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
        const username = 'this_is_a_user_name',
            password = 't/-/15_15_4_/>455w0|2|)';
        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(UsernameInput), username);
        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPassword), password);
        await tester.ourEnterText(
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

        const tooShortUsername = 'ab',
            username = 'abc',
            takenUsername = 'taken';
        final tooShortPassword =
                'p' * (CreateAccountCubit.minPasswordCreateLength - 1),
            password = 'p' * CreateAccountCubit.minPasswordCreateLength;

        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();

        await _expectErrorDialog(tester, translate.enterUsername);

        await tester.ourEnterText(find.byType(UsernameInput), tooShortUsername);

        await _expectErrorDialog(tester, translate.usernameToShort);

        await tester.ourEnterText(find.byType(UsernameInput), takenUsername);

        await _expectErrorDialog(tester, translate.enterPassword);

        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPassword), tooShortPassword);

        await _expectErrorDialog(tester, translate.passwordToShort);

        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPassword), password);

        await _expectErrorDialog(tester, translate.confirmPassword,
            matcher: findsNWidgets(2));

        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPasswordConfirm), tooShortPassword);

        await _expectErrorDialog(tester, translate.passwordMismatch);

        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPasswordConfirm), password);

        await _expectErrorDialog(tester, translate.confirmTermsOfUse);

        await tester.tap(find.byKey(TestKey.acceptTermsOfUse));
        await tester.pumpAndSettle();

        await _expectErrorDialog(tester, translate.confirmPrivacyPolicy);

        await tester.tap(find.byKey(TestKey.acceptPrivacyPolicy));
        await tester.pumpAndSettle();

        await _expectErrorDialog(tester, translate.usernameTaken);

        await tester.ourEnterText(find.byType(UsernameInput), username);

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
        expect(
            openedUrl, AcceptTermsSwitch.abiliaUrl + translate.termsOfUseUrl);
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
        expect(openedUrl,
            AcceptTermsSwitch.abiliaUrl + translate.privacyPolicyUrl);
      });
    },
    skip: !Config.isMP,
  );
}
