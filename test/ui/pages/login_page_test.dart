import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/main.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/pages/login_page.dart';

import '../../mocks.dart';

void main() {
  group('login page widget test', () {
    final secretPassword = 'pwfafawfa';
    final translate = Locales.language.values.first;
    LicenseDb mockLicenseDb;

    setUp(() {
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(null));
      when(mockTokenDb.delete()).thenAnswer((_) => Future.value(null));

      final mockDatabase = MockDatabase();
      when(mockDatabase.batch()).thenReturn(MockBatch());

      final mockSettingsDb = MockSettingsDb();
      when(mockSettingsDb.getDotsInTimepillar()).thenReturn(true);

      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(0));
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([]));
      mockLicenseDb = MockLicenseDb();
      when(mockLicenseDb.getLicenses()).thenAnswer((_) => Future.value([
            License(
                endTime: DateTime.now().add(Duration(hours: 24)),
                id: 1,
                product: MEMOPLANNER_LICENSE_NAME)
          ]));
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..fireBasePushService = mockFirebasePushService
        ..userDb = MockUserDb()
        ..baseUrlDb = MockBaseUrlDb()
        ..ticker = Ticker(stream: StreamController<DateTime>().stream)
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(activityResponse: () => [])
        ..fileStorage = MockFileStorage()
        ..userFileDb = MockUserFileDb()
        ..genericDb = MockGenericDb()
        ..settingsDb = mockSettingsDb
        ..database = mockDatabase
        ..flutterTts = MockFlutterTts()
        ..licenseDb = mockLicenseDb
        ..init();
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
      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
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
      bool textHidden() => tester
          .firstWidget<EditableText>(find.text(secretPassword))
          .obscureText;
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

      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsNothing);

      await tester.enterText_(find.byKey(TestKey.passwordInput), '');
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsNothing);
    });

    testWidgets('Error message when incorrect username or password',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
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

      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('Can login, log out, then login', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Login
      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
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
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);

      // Login
      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
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
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
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
      await tester.verifyTts(find.byType(WebLink), contains: 'myAbilia');
    });

    testWidgets('Gets no valid license dialog when no valid license',
        (WidgetTester tester) async {
      when(mockLicenseDb.getLicenses()).thenAnswer(
        (_) => Future.value([
          License(
            endTime: DateTime.now().subtract(Duration(hours: 24)),
            id: 1,
            product: MEMOPLANNER_LICENSE_NAME,
          ),
        ]),
      );
      await tester.pumpWidget(App());

      await tester.pumpAndSettle();

      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(LicenseExpiredDialog), findsOneWidget);
    });

    testWidgets(
        'Can login when valid license, but gets logged out when invalid',
        (WidgetTester tester) async {
      final pushBloc = PushBloc();
      await tester.pumpWidget(App(
        pushBloc: pushBloc,
      ));
      await tester.pumpAndSettle();
      await tester.enterText_(
          find.byKey(TestKey.passwordInput), secretPassword);
      await tester.enterText_(
          find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);

      when(mockLicenseDb.getLicenses()).thenAnswer(
        (_) => Future.value([
          License(
            endTime: DateTime.now().subtract(Duration(hours: 24)),
            id: 1,
            product: MEMOPLANNER_LICENSE_NAME,
          ),
        ]),
      );

      pushBloc.add(PushEvent('license'));
      await tester.pumpAndSettle();
      expect(find.byType(LicenseExpiredDialog), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
