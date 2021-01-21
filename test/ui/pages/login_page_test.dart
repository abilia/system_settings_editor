import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  final secretPassword = 'pwfafawfa';
  final translate = Locales.language.values.first;

  final time = DateTime(2020, 11, 11, 11, 11);
  DateTime licensExpireTime;

  setUp(() async {
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    licensExpireTime = time.add(10.days());

    final mockDatabase = MockDatabase();
    final batch = MockBatch();
    when(batch.commit()).thenAnswer((_) => Future.value([]));
    when(mockDatabase.batch()).thenReturn(batch);

    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    final mockActivityDb = MockActivityDb();
    when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(0));
    when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([]));

    GetItInitializer()
      ..sharedPreferences =
          await MockSharedPreferences.getInstance(loggedIn: false)
      ..activityDb = mockActivityDb
      ..fireBasePushService = mockFirebasePushService
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: time,
      )
      ..client = Fakes.client(
        activityResponse: () => [],
        licenseResponse: () => Fakes.licenseResponseExpires(licensExpireTime),
      )
      ..fileStorage = MockFileStorage()
      ..userFileDb = MockUserFileDb()
      ..database = mockDatabase
      ..flutterTts = MockFlutterTts()
      ..genericDb = MockGenericDb()
      ..init();
  });

  tearDown(() async {
    setupPermissions();
    await GetIt.I.reset();
  });

  testWidgets('Application starts', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Hide password button', (WidgetTester tester) async {
    // Arrange
    bool textHidden() =>
        tester.widget<EditableText>(find.text(secretPassword)).obscureText;
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    // No show/hide-button visible at all
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
    expect(find.byIcon(AbiliaIcons.hide), findsNothing);
    expect(find.byKey(TestKey.passwordInput), findsOneWidget);

    // Type password
    await tester.enterText_(find.byKey(TestKey.passwordInput), secretPassword);
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

    // Remove text then show/hide-button is not visible
    await tester.enterText_(find.byKey(TestKey.passwordInput), '');
    await tester.pump();
    expect(find.byIcon(AbiliaIcons.hide), findsNothing);
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
  });

  testWidgets('Hide password button works in password edit dialog',
      (WidgetTester tester) async {
    // Arrange
    bool textHidden() =>
        tester.firstWidget<EditableText>(find.text(secretPassword)).obscureText;
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    // Enter field password dialog
    await tester.tap(find.byKey(TestKey.passwordInput));
    await tester.pump();

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
    await tester.tap(find.byKey(TestKey.hidePassword));
    await tester.pumpAndSettle();

    // Text shows and show/hide-button visible with show icon
    expect(textHidden(), isFalse);
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
    expect(find.byIcon(AbiliaIcons.hide), findsWidgets);

    // Go back
    await tester.tap(find.byKey(TestKey.okDialog));
    await tester.pumpAndSettle();

    // Password still hidden
    expect(textHidden(), isFalse);
    expect(find.byIcon(AbiliaIcons.show), findsNothing);
    expect(find.byIcon(AbiliaIcons.hide), findsOneWidget);
  });

  testWidgets('Cant login when no password or username',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    await tester.enterText_(find.byKey(TestKey.passwordInput), secretPassword);
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsNothing);

    await tester.enterText_(find.byKey(TestKey.passwordInput), '');
    await tester.enterText_(find.byKey(TestKey.userNameInput), Fakes.username);
    await tester.pump();
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsNothing);
  });

  testWidgets('Error message when incorrect username or password',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    await tester.enterText_(find.byKey(TestKey.userNameInput), Fakes.username);
    await tester.enterText_(
        find.byKey(TestKey.passwordInput), Fakes.incorrectPassword);
    await tester.pump();
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsNothing);
    expect(find.byKey(TestKey.loginError), findsOneWidget);
  });

  testWidgets('Can login', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    await tester.pumpAndSettle();

    await tester.enterText_(find.byKey(TestKey.passwordInput), secretPassword);
    await tester.enterText_(find.byKey(TestKey.userNameInput), Fakes.username);
    await tester.pump();
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);
  });

  testWidgets('Can login, log out, then login', (WidgetTester tester) async {
    setupPermissions({Permission.systemAlertWindow: PermissionStatus.granted});
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    // Login
    await tester.enterText_(find.byKey(TestKey.passwordInput), secretPassword);
    await tester.enterText_(find.byKey(TestKey.userNameInput), Fakes.username);
    await tester.pump();
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);

    // Logout
    await tester.tap(find.byIcon(AbiliaIcons.menu));
    await tester.pumpAndSettle();
    expect(find.byType(MenuPage), findsOneWidget);
    await tester.tap(find.byType(LogoutPickField));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LogoutButton));
    await await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    // Login
    await tester.enterText_(find.byKey(TestKey.passwordInput), secretPassword);
    await tester.enterText_(find.byKey(TestKey.userNameInput), Fakes.username);
    await tester.pump();
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    await tester.verifyTts(find.byKey(TestKey.userNameInput),
        exact: translate.userName);
    await tester.enterText_(find.byKey(TestKey.userNameInput), Fakes.username);
    await tester.verifyTts(find.byKey(TestKey.userNameInput),
        exact: Fakes.username);
    await tester.verifyTts(find.byKey(TestKey.passwordInput),
        exact: translate.password);
    await tester.enterText_(
        find.byKey(TestKey.passwordInput), Fakes.incorrectPassword);
    await tester.verifyTts(find.byKey(TestKey.passwordInput),
        exact: translate.password);
    await tester.verifyTts(find.byKey(TestKey.loggInButton),
        exact: translate.login);
    await tester.pump();
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();

    await tester.verifyTts(find.byKey(TestKey.loginError),
        exact: translate.wrongCredentials);
    await tester.verifyTts(find.byKey(TestKey.loginHint),
        exact: translate.loginHint);
  });

  testWidgets('Gets no valid license dialog when no valid license',
      (WidgetTester tester) async {
    licensExpireTime = time.subtract(10.days());

    await tester.pumpWidget(App());

    await tester.pumpAndSettle();

    await tester.enterText_(find.byKey(TestKey.passwordInput), secretPassword);
    await tester.enterText_(find.byKey(TestKey.userNameInput), Fakes.username);
    await tester.pump();
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();
    expect(find.byType(LicenseErrorDialog), findsOneWidget);
  });

  testWidgets('Can login when valid license, but gets logged out when invalid',
      (WidgetTester tester) async {
    final pushBloc = PushBloc();
    await tester.pumpWidget(App(
      pushBloc: pushBloc,
    ));
    await tester.pumpAndSettle();
    await tester.enterText_(find.byKey(TestKey.passwordInput), secretPassword);
    await tester.enterText_(find.byKey(TestKey.userNameInput), Fakes.username);
    await tester.pump();
    await tester.tap(find.byKey(TestKey.loggInButton));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarPage), findsOneWidget);

    licensExpireTime = time.subtract(10.days());

    pushBloc.add(PushEvent('license'));
    await tester.pumpAndSettle();
    expect(find.byType(LicenseErrorDialog), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  group('permissions', () {
    testWidgets(
        'when fullscreen notification is NOT granted: show FullscreenAlarmInfoDialog',
        (WidgetTester tester) async {
      setupPermissions();
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(FullscreenAlarmInfoDialog), findsOneWidget);
      expect(find.byType(RequestFullscreenNotificationButton), findsOneWidget);
      await tester.tap(find.byType(RequestFullscreenNotificationButton));
      expect(openSystemAlertSettingCalls, 1);
    });

    testWidgets(
        'when fullscreen notification IS granted: show NO FullscreenAlarmInfoDialog',
        (WidgetTester tester) async {
      setupPermissions(
          {Permission.systemAlertWindow: PermissionStatus.granted});
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(FullscreenAlarmInfoDialog), findsNothing);
    });
  });
}
