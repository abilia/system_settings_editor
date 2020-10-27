import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../mocks.dart';

void main() {
  MockSettingsDb mockSettingsDb;
  MockAuthenticationBloc mockAuthenticationBloc;
  final translate = Locales.language.values.first;
  setUp(() async {
    await initializeDateFormatting();
    mockSettingsDb = MockSettingsDb();
    mockAuthenticationBloc = MockAuthenticationBloc();
    GetItInitializer()
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        builder: (context, child) => MultiBlocProvider(providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => mockAuthenticationBloc),
          BlocProvider<ActivitiesBloc>(
              create: (context) => MockActivitiesBloc()),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(settingsDb: mockSettingsDb),
          ),
          BlocProvider<PermissionBloc>(
            create: (context) => PermissionBloc(),
          ),
        ], child: child),
        home: widget,
      );

  testWidgets('Menu page shows', (WidgetTester tester) async {
    when(mockSettingsDb.getDotsInTimepillar()).thenReturn(true);
    await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutPickField), findsOneWidget);
    await tester.tap(find.byType(LogoutPickField));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutButton), findsOneWidget);
    expect(find.byType(ProfilePictureNameAndEmail), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    when(mockSettingsDb.getTextToSpeech()).thenReturn(true);
    final mockUserRepository = MockUserRepository();
    final name = 'Slartibartfast', username = 'Zaphod Beeblebrox';
    when(mockUserRepository.me(any)).thenAnswer((_) => Future.value(User(
        username: username,
        language: 'en',
        image: 'img',
        id: 0,
        type: '1',
        name: name)));

    when(mockSettingsDb.getDotsInTimepillar()).thenReturn(true);
    when(mockAuthenticationBloc.state).thenReturn(
      Authenticated(
        token: 'token',
        userId: 0,
        userRepository: mockUserRepository,
      ),
    );

    await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byType(LogoutPickField),
        exact: translate.logout);
    await tester.tap(find.byType(LogoutPickField));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byType(LogoutButton), exact: translate.logout);
    await tester.verifyTts(find.text(name), exact: name);
    await tester.verifyTts(find.text(username), exact: username);
  });

  testWidgets('Tts info page', (WidgetTester tester) async {
    when(mockSettingsDb.getTextToSpeech()).thenReturn(true);
    await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(InfoButton));
    await tester.pumpAndSettle();
    expect(find.byType(LongPressInfoDialog), findsOneWidget);
    await tester.verifyTts(find.text(translate.longPressInfoText),
        exact: translate.longPressInfoText);
  });

  testWidgets('Tts switched off', (WidgetTester tester) async {
    when(mockSettingsDb.getTextToSpeech()).thenReturn(false);
    await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(InfoButton));
    await tester.pumpAndSettle();
    expect(find.byType(LongPressInfoDialog), findsOneWidget);
    await tester.verifyNoTts(find.text(translate.longPressInfoText));
  });

  group('permission page', () {
    tearDown(setupPermissions);

    final permissionButtonFinder = find.byType(PermissionPickField);
    final permissionPageFinder = find.byType(PermissionsPage);
    final permissionSwitchFinder = find.byType(PermissionSetting);

    testWidgets('Has permission button', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();

      expect(permissionButtonFinder, findsOneWidget);
    });

    testWidgets('Permission button denied notification orange dot',
        (WidgetTester tester) async {
      setupPermissions({
        Permission.notification: PermissionStatus.denied,
        Permission.systemAlertWindow: PermissionStatus.granted,
      });
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();

      expect(find.byType(OrangeDot), findsOneWidget);
    });

    testWidgets('Permission button denied systemAlertWindow orange dot',
        (WidgetTester tester) async {
      setupPermissions({
        Permission.notification: PermissionStatus.granted,
        Permission.systemAlertWindow: PermissionStatus.denied,
      });
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();

      expect(find.byType(OrangeDot), findsOneWidget);
    });

    testWidgets('Can go to permission page', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      expect(permissionPageFinder, findsOneWidget);
    });

    testWidgets('Permission has switches all denied',
        (WidgetTester tester) async {
      setupPermissions({
        for (var key in PermissionBloc.allPermissions)
          key: PermissionStatus.denied
      });
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      // Assert - all Permission present
      expect(permissionSwitchFinder,
          findsNWidgets(PermissionBloc.allPermissions.length));
      final permissionSwitches =
          tester.widgetList<SwitchField>(find.byType(SwitchField));
      // Assert - Switches is off
      expect(permissionSwitches.any((e) => e.value), isFalse);
      // Assert - Switches there is a callback
      expect(permissionSwitches.every((e) => e.onChanged != null), isTrue);
    });

    testWidgets('Permission has switches all granted',
        (WidgetTester tester) async {
      setupPermissions({
        for (var key in PermissionBloc.allPermissions)
          key: PermissionStatus.granted
      });
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      final permissionSwitches =
          tester.widgetList<SwitchField>(find.byType(SwitchField));
      // Assert - Switches is on
      expect(permissionSwitches.every((e) => e.value), isTrue);
    });

    testWidgets('Permission tts', (WidgetTester tester) async {
      setupPermissions({Permission.notification: PermissionStatus.denied});
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      for (final permission in PermissionBloc.allPermissions) {
        // Asssert - All has tts
        await tester.verifyTts(find.byKey(ObjectKey(permission)),
            exact: permission.translate(translate));
      }

      await tester.verifyTts(
        find.byType(ErrorMessage),
        exact: translate.notificationsWarningHintText,
      );
    });

    testWidgets(
        'Permission has switches undetermined tapped calls for request permission',
        (WidgetTester tester) async {
      setupPermissions();
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();
      final allPermissions = PermissionBloc.allPermissions.toSet()
        ..remove(Permission.systemAlertWindow);

      for (final permission in allPermissions) {
        await tester.tap(find.byKey(ObjectKey(permission)));
        await tester.pumpAndSettle();
      }
      expect(requestedPermissions, containsAll(allPermissions));
    });

    testWidgets('Permission perma denied tapped opens settings',
        (WidgetTester tester) async {
      setupPermissions({
        for (var key in PermissionBloc.allPermissions)
          key: PermissionStatus.permanentlyDenied
      });
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      for (final permission in PermissionBloc.allPermissions) {
        await tester.tap(find.byKey(ObjectKey(permission)));
        await tester.pumpAndSettle();
      }

      expect(openAppSettingsCalls, PermissionBloc.allPermissions.length - 1);
      expect(openSystemAlertSettingCalls, 1);
    });

    testWidgets('Permission granted, except notifcation, tapped calls settings',
        (WidgetTester tester) async {
      setupPermissions({
        for (var key in PermissionBloc.allPermissions)
          key: PermissionStatus.granted
      });
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      final allExceptNotifcation = PermissionBloc.allPermissions.toSet()
        ..remove(Permission.notification)
        ..remove(Permission.systemAlertWindow);

      for (final permission in allExceptNotifcation) {
        await tester.tap(find.byKey(ObjectKey(permission)));
        await tester.pumpAndSettle();
      }

      expect(openAppSettingsCalls, allExceptNotifcation.length);
    });

    testWidgets('Notification granted tapped calls shows warning',
        (WidgetTester tester) async {
      setupPermissions({Permission.notification: PermissionStatus.granted});
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotificationPermissionSwitch));
      await tester.pumpAndSettle();

      expect(
          find.byType(NotificationPermissionOffWarningDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.okDialog));
      expect(openAppSettingsCalls, 1);
    });

    testWidgets('Notification denied shows warnings',
        (WidgetTester tester) async {
      setupPermissions({Permission.notification: PermissionStatus.denied});
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(AbiliaIcons.ir_error), findsOneWidget);
      expect(find.byType(ErrorMessage), findsOneWidget);
      expect(find.text(translate.notificationsWarningHintText), findsOneWidget);
    });

    testWidgets('systemAlertWindow granted tapped calls shows warning',
        (WidgetTester tester) async {
      setupPermissions(
          {Permission.systemAlertWindow: PermissionStatus.granted});
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FullscreenPermissionSwitch));
      await tester.pumpAndSettle();

      expect(
          find.byType(NotificationPermissionOffWarningDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.okDialog));
      expect(openSystemAlertSettingCalls, 1);
    });

    testWidgets('systemAlertWindow denied shows warnings',
        (WidgetTester tester) async {
      setupPermissions({Permission.notification: PermissionStatus.denied});
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(AbiliaIcons.ir_error), findsOneWidget);
      expect(find.byType(ErrorMessage), findsOneWidget);
      expect(find.text(translate.notificationsWarningHintText), findsOneWidget);
    });

    testWidgets(
        'Fullscreen Alarm Info button shows FullscreenAlarmInfoDialog without RequestFullScreenNotificationButton',
        (WidgetTester tester) async {
      setupPermissions({Permission.systemAlertWindow: PermissionStatus.denied});

      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InfoButton));
      await tester.pumpAndSettle();

      expect(find.byType(FullscreenAlarmInfoDialog), findsOneWidget);
      expect(find.byType(RequestFullscreenNotificationButton), findsNothing);
    });
  });
}
