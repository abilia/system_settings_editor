import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info/package_info.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../fakes/all.dart';
import '../../../../fakes/fakes_blocs.dart';
import '../../../../mocks/shared.mocks.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  final user = User(
      id: 1,
      name: 'Slartibartfast',
      username: 'Zaphod Beeblebrox',
      type: 'type');

  final translate = Locales.language.values.first;
  setUp(() async {
    setupFakeTts();
    await initializeDateFormatting();

    final userDb = MockUserDb();
    when(userDb.getUser()).thenReturn(user);
    GetItInitializer()
      ..userDb = userDb
      ..packageInfo = PackageInfo(
          appName: 'appName',
          packageName: 'packageName',
          version: 'version',
          buildNumber: 'buildNumber')
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = MockDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        builder: (context, child) => FakeAuthenticatedBlocsProvider(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthenticationBloc>(
                  create: (context) => FakeAuthenticationBloc()),
              BlocProvider<SettingsBloc>(
                create: (context) => SettingsBloc(settingsDb: FakeSettingsDb()),
              ),
              BlocProvider<ActivitiesBloc>(
                create: (context) => FakeActivitiesBloc(),
              ),
              BlocProvider<TimepillarBloc>(
                create: (context) => FakeTimepillarBloc(),
              )
            ],
            child: child!,
          ),
        ),
        home: widget,
      );

  group('permission page', () {
    tearDown(setupPermissions);

    final permissionButtonFinder = find.byType(PermissionPickField);
    final permissionPageFinder = find.byType(PermissionsPage);
    final permissionSwitchFinder =
        find.byType(PermissionSetting, skipOffstage: false);

    testWidgets('Has permission button', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
      await tester.pumpAndSettle();

      expect(permissionButtonFinder, findsOneWidget);
    });

    testWidgets('Permission button denied notification orange dot',
        (WidgetTester tester) async {
      setupPermissions({
        Permission.notification: PermissionStatus.denied,
        Permission.systemAlertWindow: PermissionStatus.granted,
      });
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
      await tester.pumpAndSettle();

      expect(find.byType(OrangeDot), findsOneWidget);
    });

    testWidgets('Permission button denied systemAlertWindow orange dot',
        (WidgetTester tester) async {
      setupPermissions({
        Permission.notification: PermissionStatus.granted,
        Permission.systemAlertWindow: PermissionStatus.denied,
      });
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
      await tester.pumpAndSettle();

      expect(find.byType(OrangeDot), findsOneWidget);
    });

    testWidgets('Can go to permission page', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
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
        'Permission has switches denied tapped calls for request permission',
        (WidgetTester tester) async {
      final allPermissions = PermissionBloc.allPermissions.toSet()
        ..remove(Permission.systemAlertWindow)
        ..remove(Permission.notification);

      setupPermissions(
          {for (var k in allPermissions) k: PermissionStatus.denied});
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

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
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      final perms = PermissionBloc.allPermissions;

      for (final permission in perms) {
        await tester.tap(find.byKey(ObjectKey(permission)));
        await tester.scrollDown();
        await tester.pumpAndSettle();
      }

      expect(openAppSettingsCalls, perms.length - 1);
    });

    testWidgets('Permission granted, except notifcation, tapped calls settings',
        (WidgetTester tester) async {
      setupPermissions({
        for (var key in PermissionBloc.allPermissions)
          key: PermissionStatus.granted
      });
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FullscreenPermissionSwitch));
      await tester.pumpAndSettle();

      expect(
          find.byType(NotificationPermissionOffWarningDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.okDialog));
      await tester.pumpAndSettle();
    });

    testWidgets('systemAlertWindow denied shows warnings',
        (WidgetTester tester) async {
      setupPermissions({Permission.notification: PermissionStatus.denied});
      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
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

      await tester.pumpWidget(wrapWithMaterialApp(SystemSettingsPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InfoButton));
      await tester.pumpAndSettle();

      expect(find.byType(FullscreenAlarmInfoDialog), findsOneWidget);
      expect(find.byType(RequestFullscreenNotificationButton), findsNothing);
      expect(find.text(translate.notificationsWarningHintText), findsNothing);
    });
  });
}

extension on WidgetTester {
  Future scrollDown({double dy = -30.0}) async {
    final center = getCenter(find.byType(PermissionsPage));
    await dragFrom(center, Offset(0.0, dy));
    await pump();
  }
}
