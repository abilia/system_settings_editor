import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

import 'package:sortables/db/sortable_db.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';
import '../../../test_helpers/tts.dart';

void main() {
  const secretPassword = 'pwfafawfapwfafawfa';
  final translate = Locales.language.values.first;

  final time = DateTime(2020, 11, 11, 11, 11);
  DateTime licensExpireTime;
  late ListenableMockClient client;
  TermsOfUseResponse termsOfUseResponse = () => TermsOfUse.accepted();

  setUpAll(() {
    registerFallbackValues();
    scheduleNotificationsIsolated = noAlarmScheduler;
    licensExpireTime = time.add(10.days());
    client = Fakes.client(
      activityResponse: () => [],
      licenseResponse: () => Fakes.licenseResponseExpires(licensExpireTime),
      termsOfUseResponse: () => termsOfUseResponse(),
      tooManyAttemptsResponse: () => Response('', 429),
    );
  });

  late SortableDb sortableDb;

  setUp(() async {
    setupPermissions({Permission.systemAlertWindow: PermissionStatus.granted});
    setupFakeTts();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    licensExpireTime = time.add(10.days());

    sortableDb = MockSortableDb();
    when(() => sortableDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(defaultSortables));
    when(() => sortableDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));
    when(() => sortableDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => sortableDb.countAllDirty()).thenAnswer((_) => Future.value(0));

    GetItInitializer()
      ..sharedPreferences =
          await FakeSharedPreferences.getInstance(loggedIn: false)
      ..activityDb = FakeActivityDb()
      ..fireBasePushService = FakeFirebasePushService()
      ..ticker = Ticker.fake(initialTime: time)
      ..client = client
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..database = FakeDatabase()
      ..genericDb = FakeGenericDb()
      ..sessionsDb = FakeSessionsDb()
      ..sortableDb = sortableDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() async {
    Fakes.resetLoginAttempts();
    setupPermissions();
    termsOfUseResponse = () => TermsOfUse.accepted();
    await GetIt.I.reset();
  });

  testWidgets('Application starts', (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Hide password button', (WidgetTester tester) async {
    // Arrange
    bool textHidden() =>
        tester.widget<EditableText>(find.text(secretPassword)).obscureText;
    await tester.pumpApp();
    await tester.pumpAndSettle();

    // No show/hide-button visible at all
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
    expect(find.byIcon(AbiliaIcons.hide), findsNothing);
    expect(find.byType(PasswordInput), findsOneWidget);

    // Type password
    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.pumpAndSettle();

    // Text hidden but show/hide-button visible
    expect(textHidden(), isTrue);
    expect(find.byIcon(AbiliaIcons.hide), findsNothing);
    expect(find.byIcon(AbiliaIcons.show), findsOneWidget);

    // Tap show/hide-button
    await tester.tap(find.byIcon(AbiliaIcons.show));
    await tester.pumpAndSettle();

    // Text shows and show/hide-button visible with show icon
    expect(textHidden(), isFalse);
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
    expect(find.byIcon(AbiliaIcons.hide), findsOneWidget);
  });

  testWidgets('Hide password button works in password edit dialog',
      (WidgetTester tester) async {
    // Arrange
    bool textHidden() =>
        tester.firstWidget<EditableText>(find.text(secretPassword)).obscureText;
    await tester.pumpApp();
    await tester.pumpAndSettle();

    // Enter field password dialog
    await tester.tap(find.byType(PasswordInput), warnIfMissed: false);
    await tester.pumpAndSettle();

    // No button shows at all
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
    expect(find.byIcon(AbiliaIcons.hide), findsNothing);
    expect(find.byKey(TestKey.input), findsOneWidget);

    await tester.enterText(find.byKey(TestKey.input), secretPassword);
    await tester.pumpAndSettle();

    // Text hidden but hide button shows
    expect(textHidden(), isTrue);
    expect(find.byIcon(AbiliaIcons.hide), findsNothing);
    expect(find.byIcon(AbiliaIcons.show), findsWidgets);

    // Tap show/hide-button
    await tester.tap(find.byKey(TestKey.bottomSheetHidePasswordButton));
    await tester.pumpAndSettle();

    // Text shows and show/hide-button visible with show icon
    expect(textHidden(), isFalse);
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
    expect(find.byIcon(AbiliaIcons.hide), findsWidgets);

    // Go back
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Password still hidden
    expect(textHidden(), isFalse);
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
    expect(find.byIcon(AbiliaIcons.hide), findsOneWidget);
  });

  testWidgets('Login button pressed when no username shows error dialog',
      (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorDialog), findsOneWidget);
    expect(find.text(translate.enterUsername), findsOneWidget);
  });

  testWidgets('Login button pressed when no password shows error dialog',
      (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();

    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    expect(find.byType(LoginButton), findsOneWidget);

    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorDialog), findsOneWidget);
    expect(find.text(translate.enterPassword), findsOneWidget);
  });

  testWidgets('Error message when incorrect username or password',
      (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();

    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.ourEnterText(
        find.byType(PasswordInput), Fakes.incorrectPassword);
    await tester.pump();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsNothing);
    expect(find.byType(ErrorDialog), findsOneWidget);
    expect(find.text(translate.wrongCredentials), findsOneWidget);
  });

  testWidgets('Can login', (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();
    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);
  });

  testWidgets('Can login, log out, then login', (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();

    // Login
    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.pump();
    expect(find.byType(LoginButton), findsOneWidget);
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);

    // Logout
    if (Config.isMP) {
      await tester.tap(find.byIcon(AbiliaIcons.appMenu));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.settings));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(AbiliaIcons.technicalSettings));
      await tester.pumpAndSettle();
    } else if (Config.isMPGO) {
      await tester.tap(find.byIcon(AbiliaIcons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(MpGoMenuPage), findsOneWidget);
      await tester.scrollDownMpGoMenu(dy: -200);
    }
    await tester.tap(find.byIcon(AbiliaIcons.powerOffOn));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LogoutButton));
    await tester.pumpAndSettle();

    // Login
    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.pump();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();

    await tester.verifyTts(find.byType(UsernameInput),
        exact: translate.usernameHint);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.verifyTts(find.byType(UsernameInput), exact: Fakes.username);
    await tester.verifyTts(find.text(translate.password),
        exact: translate.password);
    await tester.ourEnterText(
        find.byType(PasswordInput), Fakes.incorrectPassword);
    await tester.verifyTts(find.byType(LoginButton), exact: translate.login);
    await tester.pump();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();

    await tester.verifyTts(find.text(translate.wrongCredentials),
        exact: translate.wrongCredentials);
  });

  testWidgets('tts mpgo hint text', (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();
    await tester.verifyTts(find.text(translate.loginHintMPGO),
        exact: translate.loginHintMPGO);
  }, skip: !Config.isMPGO);

  testWidgets('tts mp hint text', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpApp();
    await tester.pumpAndSettle();
    await tester.verifyTts(find.text(translate.loginHintMP),
        exact: translate.loginHintMP);
  }, skip: !Config.isMP);

  testWidgets('Gets no valid license dialog when no valid license',
      (WidgetTester tester) async {
    licensExpireTime = time.subtract(10.days());

    await tester.pumpApp();

    await tester.pumpAndSettle();

    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.pump();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(LicenseErrorDialog), findsOneWidget);
  }, skip: Config.isMP);

  testWidgets('Can login when valid license, but gets logged out when invalid',
      (WidgetTester tester) async {
    final pushCubit = PushCubit();
    await tester.pumpApp(pushCubit: pushCubit);
    await tester.pumpAndSettle();
    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarPage), findsOneWidget);

    licensExpireTime = time.subtract(10.days());

    pushCubit.fakePush();
    await tester.pumpAndSettle();
    expect(find.byType(LicenseErrorDialog), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  }, skip: Config.isMP);

  testWidgets('Can login when valid license, warning when expires',
      (WidgetTester tester) async {
    final pushCubit = PushCubit();
    await tester.pumpApp(pushCubit: pushCubit);
    await tester.pumpAndSettle();
    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);

    licensExpireTime = time.subtract(10.days());

    pushCubit.fakePush();
    await tester.pumpAndSettle();

    expect(find.byType(LicenseErrorDialog), findsNothing);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(CalendarPage), findsOneWidget);
    expect(find.byType(WarningDialog), findsOneWidget);
  }, skip: Config.isMPGO);

  testWidgets('Can login when no valid expired license, sync warning',
      (WidgetTester tester) async {
    licensExpireTime = time.subtract(10.days());

    await tester.pumpApp();

    await tester.pumpAndSettle();

    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.licenseExpiredMessage), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);

    expect(find.byType(LicenseErrorDialog), findsNothing);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(CalendarPage), findsOneWidget);
  }, skip: Config.isMPGO);

  testWidgets('Error message when incorrect user type',
      (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();

    await tester.ourEnterText(
        find.byType(UsernameInput), Fakes.supportUserName);
    await tester.ourEnterText(
        find.byType(PasswordInput), Fakes.incorrectPassword);
    await tester.pump();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsNothing);
    expect(find.byType(ErrorDialog), findsOneWidget);
    expect(find.text(translate.userTypeNotSupported), findsOneWidget);
    expect(find.text(translate.loggedOutMessage), findsNothing);
  });

  testWidgets('Cant press OK with too short username',
      (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(UsernameInput), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.input), 'a');
    await tester.pumpAndSettle();
    final button = tester.widget<OkButton>(find.byType(OkButton));
    expect(button.onPressed, null);

    await tester.tap(find.byType(CancelButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Cant press OK with empty password', (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PasswordInput), warnIfMissed: false);
    await tester.pumpAndSettle();
    final button = tester.widget<OkButton>(find.byType(OkButton));
    expect(button.onPressed, null);

    await tester.tap(find.byType(CancelButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('username not changed when cancle cancelling username',
      (WidgetTester tester) async {
    const testUsername = 'testUsername';
    await tester.pumpApp();
    await tester.pumpAndSettle();
    await tester.ourEnterText(find.byType(UsernameInput), testUsername);
    expect(find.text(testUsername), findsOneWidget);
    await tester.tap(find.byType(UsernameInput), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.input), Fakes.username);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CancelButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text(Fakes.username), findsNothing);
    expect(find.text(testUsername), findsOneWidget);
  });

  testWidgets('password not changed when cancel is pressed',
      (WidgetTester tester) async {
    await tester.pumpApp();
    await tester.pumpAndSettle();
    const pw = 'some password still there';

    await tester.ourEnterText(find.byType(PasswordInput), pw);
    await tester.tap(find.byIcon(AbiliaIcons.show));
    await tester.pumpAndSettle();

    expect(find.text(pw), findsOneWidget);

    await tester.tap(find.byType(PasswordInput), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.input), secretPassword);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CancelButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text(pw), findsOneWidget);
    expect(find.text(secretPassword), findsNothing);
  });

  testWidgets('Redirect to login when unauthorized',
      (WidgetTester tester) async {
    tester.setScreenSize(const Size(500, 800));
    await tester.pumpApp();
    await tester.pumpAndSettle();
    await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
    await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);

    client.fakeUnauthorized();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text(translate.loggedOutMessage), findsOneWidget);
  });

  group('Login footer', () {
    testWidgets('Login footer only on MP', (WidgetTester tester) async {
      await tester.pumpApp();
      expect(find.byType(MEMOplannerLoginFooter),
          Config.isMP ? findsOneWidget : findsNothing);
    });

    testWidgets('Login footer buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SpeechSettingsCubit>(
            create: (_) => FakeSpeechSettingsCubit(),
            child: Builder(
              builder: (context) {
                return const MEMOplannerLoginFooter();
              },
            ),
          ),
        ),
      );
      expect(find.byType(AbiliaLogoWithReset), findsOneWidget);
      expect(find.byType(AboutButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.settings), findsOneWidget);

      await tester.tap(find.byType(AboutButton));
      await tester.pumpAndSettle();

      expect(find.byType(AboutDialog), findsOneWidget);
    });
  });

  group('on login popups', () {
    group('Terms of use', () {
      testWidgets('When terms of use is accepted, show no terms of use dialog',
          (WidgetTester tester) async {
        termsOfUseResponse = () => TermsOfUse.accepted();
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(AuthenticatedDialog), findsNothing);
        expect(find.byType(TermsOfUseDialog), findsNothing);
        // No other dialog is pending, expect no next button.
        expect(find.byType(NextButton), findsNothing);
      });

      testWidgets('When terms of use is not accepted, show terms of use dialog',
          (WidgetTester tester) async {
        termsOfUseResponse = () =>
            const TermsOfUse(termsOfCondition: false, privacyPolicy: false);
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(AuthenticatedDialog), findsOneWidget);
        expect(find.byType(TermsOfUseDialog), findsOneWidget);
      });

      testWidgets('When click on logout button, logout back to login page',
          (WidgetTester tester) async {
        termsOfUseResponse = () =>
            const TermsOfUse(termsOfCondition: false, privacyPolicy: false);
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(AuthenticatedDialog), findsOneWidget);
        expect(find.byType(TermsOfUseDialog), findsOneWidget);

        await tester.tap(find.byType(LogoutButton));
        await tester.pumpAndSettle();
        expect(find.byType(LoginPage), findsOneWidget);
      });
    });

    group('Starter set', () {
      testWidgets('When no sortables, show StarterSetDialog',
          (WidgetTester tester) async {
        when(() => sortableDb.insertAndAddDirty(any())).thenAnswer((_) {
          when(() => sortableDb.getAllNonDeleted())
              .thenAnswer((_) => Future.value(defaultSortables));
          return Future.value(true);
        });
        when(() => sortableDb.getAllNonDeleted())
            .thenAnswer((_) => Future.value([]));
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(AuthenticatedDialog), findsOneWidget);
        expect(find.byType(StarterSetDialog), findsOneWidget);
      });

      testWidgets('When some sortable, show no StarterSetDialog',
          (WidgetTester tester) async {
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(StarterSetDialog), findsNothing);
      });
    });

    group('All dialogs', () {
      group('Permissions', () {
        testWidgets(
            'When fullscreen notification is NOT granted on MPGO, show FullscreenAlarmInfoDialog',
            (WidgetTester tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.android;
          setupPermissions(
              {Permission.systemAlertWindow: PermissionStatus.denied});
          await tester.pumpApp();
          await tester.pumpAndSettle();
          await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
          await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
          await tester.pump();
          await tester.tap(find.byType(LoginButton));
          await tester.pumpAndSettle();
          expect(find.byType(AuthenticatedDialog), findsOneWidget);
          expect(find.byType(FullscreenAlarmInfoDialog), findsOneWidget);
          await tester.tap(find.byType(GreenButton));
          expect(requestedPermissions, contains(Permission.systemAlertWindow));
          debugDefaultTargetPlatformOverride = null;
        });

        testWidgets(
            'When fullscreen notification is NOT granted on iOS, show NO FullscreenAlarmInfoDialog',
            (WidgetTester tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
          await tester.pumpApp();
          await tester.pumpAndSettle();
          await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
          await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
          await tester.pump();
          await tester.tap(find.byType(LoginButton));
          await tester.pumpAndSettle();
          expect(find.byType(AuthenticatedDialog), findsNothing);
          expect(find.byType(FullscreenAlarmInfoDialog), findsNothing);
          debugDefaultTargetPlatformOverride = null;
        });

        testWidgets(
            'When fullscreen notification IS granted, show NO FullscreenAlarmInfoDialog',
            (WidgetTester tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.android;
          await tester.pumpApp();
          await tester.pumpAndSettle();
          await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
          await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
          await tester.pump();
          await tester.tap(find.byType(LoginButton));
          await tester.pumpAndSettle();
          expect(find.byType(FullscreenAlarmInfoDialog), findsNothing);
          debugDefaultTargetPlatformOverride = null;
        });
      }, skip: Config.isMP);

      testWidgets(
          'When terms of use is not accepted, sortables is empty '
          'and fullscreen notification is not granted, show all dialogs',
          (WidgetTester tester) async {
        // Arrange
        tester.setScreenSize(const Size(500, 800));
        termsOfUseResponse = () =>
            const TermsOfUse(termsOfCondition: false, privacyPolicy: false);
        when(() => sortableDb.getAllNonDeleted())
            .thenAnswer((_) => Future.value([]));
        when(() => sortableDb.insertAndAddDirty(any())).thenAnswer((_) {
          when(() => sortableDb.getAllNonDeleted())
              .thenAnswer((_) => Future.value(defaultSortables));
          return Future.value(true);
        });
        setupPermissions(
            {Permission.systemAlertWindow: PermissionStatus.denied});

        // Act - Login
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();

        // Assert - Terms of use dialog shows
        expect(find.byType(AuthenticatedDialog), findsOneWidget);
        expect(find.byType(TermsOfUseDialog), findsOneWidget);

        // Act - Accept terms of use
        await tester.tap(find.byType(Switch).first);
        await tester.tap(find.byType(Switch).last);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        // Assert - Starter set dialog shows
        expect(find.byType(StarterSetDialog), findsOneWidget);

        // Act - Deny starter set
        await tester.tap(find.byType(NoButton));
        await tester.pumpAndSettle();

        // Assert - Fullscreen alarm dialog shows on MPGO
        // Act - Close dialog if MPGO
        if (Config.isMPGO) {
          expect(find.byType(FullscreenAlarmInfoDialog), findsOneWidget);
          await tester.tap(find.byType(CancelButton));
          await tester.pumpAndSettle();
        }

        // Assert - Calendar page shows
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      testWidgets(
          'When terms of use is not accepted, sortables is not empty '
          'and fullscreen notification is not granted, '
          'show terms of use dialog and full screen alarm dialog',
          (WidgetTester tester) async {
        // Arrange
        termsOfUseResponse = () =>
            const TermsOfUse(termsOfCondition: false, privacyPolicy: false);
        setupPermissions(
            {Permission.systemAlertWindow: PermissionStatus.denied});

        // Act - Login
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();

        // Assert - Terms of use dialog shows
        expect(find.byType(AuthenticatedDialog), findsOneWidget);
        expect(find.byType(TermsOfUseDialog), findsOneWidget);

        // Act - Accept terms of use
        await tester.tap(find.byType(Switch).first);
        await tester.tap(find.byType(Switch).last);
        await tester.pumpAndSettle();

        // Act - If MPGO, next button is shown as full screen alarm is still to be shown.
        await tester.tap(find.byType(Config.isMPGO ? NextButton : GreenButton));
        await tester.pumpAndSettle();

        if (Config.isMPGO) {
          // Assert - Fullscreen alarm dialog shows on MPGO
          expect(find.byType(FullscreenAlarmInfoDialog), findsOneWidget);

          // Act - Close dialog if MPGO
          await tester.tap(find.byType(CancelButton));
          await tester.pumpAndSettle();
        }

        // Assert - Calendar page shows
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      testWidgets(
          'When terms of use is accepted, sortables is empty '
          'and fullscreen notification is not granted, '
          'show starter set dialog and full screen alarm dialog',
          (WidgetTester tester) async {
        // Arrange
        tester.setScreenSize(const Size(500, 800));
        termsOfUseResponse = () => TermsOfUse.accepted();
        when(() => sortableDb.getAllNonDeleted())
            .thenAnswer((_) => Future.value([]));
        when(() => sortableDb.insertAndAddDirty(any())).thenAnswer((_) {
          when(() => sortableDb.getAllNonDeleted())
              .thenAnswer((_) => Future.value(defaultSortables));
          return Future.value(true);
        });
        setupPermissions(
            {Permission.systemAlertWindow: PermissionStatus.denied});

        // Act - Login
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();

        // Assert - Starter set dialog shows
        expect(find.byType(AuthenticatedDialog), findsOneWidget);
        expect(find.byType(StarterSetDialog), findsOneWidget);

        // Act - Deny starter set
        await tester.tap(find.byType(NoButton));
        await tester.pumpAndSettle();

        // Assert - Fullscreen alarm dialog shows on MPGO
        expect(find.byType(FullscreenAlarmInfoDialog),
            Config.isMPGO ? findsOneWidget : findsNothing);

        // Act - Close dialog if MPGO
        if (Config.isMPGO) {
          await tester.tap(find.byType(CancelButton));
          await tester.pumpAndSettle();
        }

        // Assert - Calendar page shows
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      testWidgets(
          'When terms of use is not accepted, sortables is empty '
          'and fullscreen notification is granted, '
          'show starter terms of use dialog and set dialog',
          (WidgetTester tester) async {
        // Arrange
        tester.setScreenSize(const Size(500, 800));
        termsOfUseResponse = () => TermsOfUse.accepted();
        when(() => sortableDb.getAllNonDeleted())
            .thenAnswer((_) => Future.value([]));
        when(() => sortableDb.insertAndAddDirty(any())).thenAnswer((_) {
          when(() => sortableDb.getAllNonDeleted())
              .thenAnswer((_) => Future.value(defaultSortables));
          return Future.value(true);
        });
        setupPermissions(
            {Permission.systemAlertWindow: PermissionStatus.granted});

        // Act - Login
        await tester.pumpApp();
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();

        // Assert - Starter set dialog shows
        expect(find.byType(AuthenticatedDialog), findsOneWidget);
        expect(find.byType(StarterSetDialog), findsOneWidget);

        // Act - Deny starter set
        await tester.tap(find.byType(NoButton));
        await tester.pumpAndSettle();

        // Assert - Calendar page shows
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      testWidgets('SGC-2463 - Too many login attempts dialog',
          (WidgetTester tester) async {
        await tester.pumpApp();
        await tester.pumpAndSettle();

        await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
        await tester.ourEnterText(
            find.byType(PasswordInput), Fakes.incorrectPassword);
        await tester.pump();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(ErrorDialog), findsOneWidget);
        await tester.tap(find.byType(PreviousButton));
        await tester.pumpAndSettle();
        await tester.ourEnterText(find.byType(PasswordInput), secretPassword);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsNothing);
        expect(find.byType(ErrorDialog), findsOneWidget);
        expect(find.text(translate.tooManyAttempts), findsOneWidget);
      });
    });
  });
}

extension on WidgetTester {
  Future scrollDownMpGoMenu({double dy = -800.0}) async {
    final center = getCenter(find.byType(MpGoMenuPage));
    await dragFrom(center, Offset(0.0, dy));
    await pump();
  }
}
