import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_fakes/all.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/tap_link.dart';

void main() {
  setUpAll(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });
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
        expect(find.byKey(TestKey.acceptTermsOfUse), findsOneWidget);
        expect(find.byKey(TestKey.acceptPrivacyPolicy), findsOneWidget);
        await tester.tap(find.byType(Switch).first);
        await tester.tap(find.byType(Switch).last);
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
        Future expectErrorDialog(WidgetTester tester, String errorMessage,
            {Matcher matcher = findsOneWidget}) async {
          await tester.tap(find.byType(CreateAccountButton));
          await tester.pumpAndSettle();
          expect(find.byType(ErrorDialog), findsOneWidget);
          expect(find.text(errorMessage), matcher);
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
        }

        const username = 'abc', takenUsername = 'taken';
        final tooShortPassword =
                'p' * (CreateAccountCubit.minPasswordCreateLength - 1),
            password = 'p' * CreateAccountCubit.minPasswordCreateLength;

        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();

        await expectErrorDialog(tester, translate.enterUsername);

        await tester.ourEnterText(find.byType(UsernameInput), takenUsername);

        await expectErrorDialog(tester, translate.enterPassword);

        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPassword), tooShortPassword);

        await expectErrorDialog(tester, translate.passwordToShort);

        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPassword), password);

        await expectErrorDialog(tester, translate.confirmPassword,
            matcher: findsNWidgets(2));

        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPasswordConfirm), tooShortPassword);

        await expectErrorDialog(tester, translate.passwordMismatch);

        await tester.ourEnterText(
            find.byKey(TestKey.createAccountPasswordConfirm), password);

        await expectErrorDialog(tester, translate.confirmTermsOfUse);

        await tester.tap(find.byType(Switch).first);
        await tester.pumpAndSettle();

        await expectErrorDialog(tester, translate.confirmPrivacyPolicy);

        await tester.tap(find.byType(Switch).last);
        await tester.pumpAndSettle();

        await expectErrorDialog(tester, translate.usernameTaken);

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
            tester.widget<WebViewDialog>(find.byType(WebViewDialog)).url;
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
            tester.widget<WebViewDialog>(find.byType(WebViewDialog)).url;
        expect(openedUrl,
            AcceptTermsSwitch.abiliaUrl + translate.privacyPolicyUrl);
      });

      bool isOkButtonEnabled(WidgetTester tester) {
        return tester.widget<OkButton>(find.byKey(TestKey.inputOk)).onPressed !=
            null;
      }

      testWidgets(
          'SGC-2018 - Must input a username within allowed character range',
          (tester) async {
        final tooShortUserName = 'a' * (LoginCubit.minUsernameLength - 1);
        final tooLongUserName = 'a' * (CreateAccountPage.maxUsernameLength + 1);
        final userNameWithinRange = 'a' * 10;
        await tester.pumpApp();
        await tester.tap(find.byType(GoToCreateAccountButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(UsernameInput), warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(TestKey.input), tooShortUserName);
        await tester.pumpAndSettle();
        expect(isOkButtonEnabled(tester), isFalse);

        await tester.enterText(find.byKey(TestKey.input), tooLongUserName);
        await tester.pumpAndSettle();
        expect(isOkButtonEnabled(tester), isFalse);

        await tester.enterText(find.byKey(TestKey.input), userNameWithinRange);
        await tester.pumpAndSettle();
        expect(isOkButtonEnabled(tester), isTrue);
      });
    },
    skip: !Config.isMP,
  );
}
