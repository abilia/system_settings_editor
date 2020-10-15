import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
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
    await tester.tap(find.byKey(TestKey.ttsInfoButton));
    await tester.pumpAndSettle();
    expect(find.byType(LongPressInfoDialog), findsOneWidget);
    await tester.verifyTts(find.text(translate.longPressInfoText),
        exact: translate.longPressInfoText);
  });

  testWidgets('Tts switched off', (WidgetTester tester) async {
    when(mockSettingsDb.getTextToSpeech()).thenReturn(false);
    await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.ttsInfoButton));
    await tester.pumpAndSettle();
    expect(find.byType(LongPressInfoDialog), findsOneWidget);
    await tester.verifyNoTts(find.text(translate.longPressInfoText));
  });

  group('permission page', () {
    tearDown(() {
      checkedPermissions.clear();
      requestedPermissions.clear();
      openAppSettingsCalls = 0;
    });
    final permissionButtonFinder = find.byType(PermissionPickField);
    final permissionPageFinder = find.byType(PermissionsPage);
    final permissionSwitchFinder = find.byType(PermissionSwitch);

    testWidgets('Has permission button', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();

      expect(permissionButtonFinder, findsOneWidget);
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
      // Assert - Can't be pressed
      expect(permissionSwitches.every((e) => e.onChanged == null), isTrue);
    });

    testWidgets('Permission has switches tts', (WidgetTester tester) async {
      setupPermissions();
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      for (final permission in PermissionBloc.allPermissions) {
        // Asssert - All has tts
        await tester.verifyTts(find.byKey(ObjectKey(permission)),
            exact: permission.translate(translate));
      }
    });

    testWidgets(
        'Permission has switches undetermined tapped calls for request permission',
        (WidgetTester tester) async {
      setupPermissions();
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      for (final permission in PermissionBloc.allPermissions) {
        await tester.tap(find.byKey(ObjectKey(permission)));
        await tester.pumpAndSettle();
      }
      expect(requestedPermissions, containsAll(PermissionBloc.allPermissions));
    });

    testWidgets(
        'Permission has switches undetermined tapped calls for request permission',
        (WidgetTester tester) async {
      setupPermissions({
        for (var key in PermissionBloc.allPermissions)
          key: PermissionStatus.denied
      });
      await tester.pumpWidget(wrapWithMaterialApp(MenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      for (final permission in PermissionBloc.allPermissions) {
        await tester.tap(find.byKey(ObjectKey(permission)));
        await tester.pumpAndSettle();
      }

      expect(openAppSettingsCalls, PermissionBloc.allPermissions.length);
    });
  });
}
