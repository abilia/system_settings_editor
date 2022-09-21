import 'package:flutter_test/flutter_test.dart';

import 'package:package_info/package_info.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';
import '../../../test_helpers/tts.dart';

void main() {
  const user = User(
      id: 1,
      name: 'Slartibartfast',
      username: 'Zaphod Beeblebrox',
      type: 'type');

  final translate = Locales.language.values.first;
  setUp(() async {
    setupFakeTts();
    registerFallbackValues();
    await initializeDateFormatting();

    final userDb = MockUserDb();
    when(() => userDb.getUser()).thenReturn(user);
    GetItInitializer()
      ..userDb = userDb
      ..packageInfo = PackageInfo(
          appName: 'appName',
          packageName: 'packageName',
          version: 'version',
          buildNumber: 'buildNumber')
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        builder: (context, child) => FakeAuthenticatedBlocsProvider(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthenticationBloc>(
                  create: (context) => FakeAuthenticationBloc()),
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
              ),
              BlocProvider<ActivitiesBloc>(
                create: (context) => FakeActivitiesBloc(),
              ),
              BlocProvider<TimepillarCubit>(
                create: (context) => FakeTimepillarCubit(),
              ),
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  screenTimeoutCallback: Future.value(30.minutes()),
                  memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                  battery: FakeBattery(),
                ),
              ),
              BlocProvider<TimerCubit>(
                create: (context) => MockTimerCubit(),
              ),
              BlocProvider<DayPartCubit>(
                create: (context) => FakeDayPartCubit(),
              ),
              BlocProvider<SessionCubit>(
                create: (context) => FakeSessionCubit(),
              )
            ],
            child: child!,
          ),
        ),
        home: widget,
      );

  group('Permission page', () {
    tearDown(setupPermissions);

    final permissionButtonFinder = find.byType(PermissionPickField);
    final permissionPageFinder = find.byType(PermissionsPage);
    final permissionSwitchFinder =
        find.byType(PermissionSetting, skipOffstage: false);

    testWidgets('Has permission button', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();

      expect(permissionButtonFinder, findsOneWidget);
    });

    testWidgets('Permission button denied notification orange dot',
        (WidgetTester tester) async {
      setupPermissions({
        Permission.notification: PermissionStatus.denied,
        Permission.systemAlertWindow: PermissionStatus.granted,
      });
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();

      expect(find.byType(OrangeDot), findsOneWidget);
    });

    testWidgets('Permission button denied systemAlertWindow orange dot',
        (WidgetTester tester) async {
      setupPermissions({
        Permission.notification: PermissionStatus.granted,
        Permission.systemAlertWindow: PermissionStatus.denied,
      });
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();

      expect(find.byType(OrangeDot), findsOneWidget);
    });

    testWidgets('Can go to permission page', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      expect(permissionPageFinder, findsOneWidget);
    });

    testWidgets('Permission has switches all denied',
        (WidgetTester tester) async {
      setupPermissions({
        for (var key in PermissionCubit.allPermissions)
          key: PermissionStatus.denied
      });
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      // Assert - all Permission present
      expect(permissionSwitchFinder,
          findsNWidgets(PermissionCubit.allPermissions.length));
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
        for (var key in PermissionCubit.allPermissions)
          key: PermissionStatus.granted
      });
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      for (final permission in PermissionCubit.allPermissions) {
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
      final allPermissions = PermissionCubit.allPermissions.toSet()
        ..remove(Permission.systemAlertWindow)
        ..remove(Permission.notification);

      setupPermissions(
          {for (var k in allPermissions) k: PermissionStatus.denied});
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
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
        for (var key in PermissionCubit.allPermissions)
          key: PermissionStatus.permanentlyDenied
      });
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      final perms = PermissionCubit.allPermissions;

      for (final permission in perms) {
        await tester.scrollTo(find.byKey(ObjectKey(permission)));
        await tester.tap(find.byKey(ObjectKey(permission)));
        await tester.pumpAndSettle();
      }

      expect(openAppSettingsCalls, perms.length - 1);
    });

    testWidgets('Permission granted, except notifcation, tapped calls settings',
        (WidgetTester tester) async {
      setupPermissions({
        for (var key in PermissionCubit.allPermissions)
          key: PermissionStatus.granted
      });
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      final allExceptNotifcation = PermissionCubit.allPermissions.toSet()
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
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(AbiliaIcons.irError), findsOneWidget);
      expect(find.byType(ErrorMessage), findsOneWidget);
      expect(find.text(translate.notificationsWarningHintText), findsOneWidget);
    });

    testWidgets('systemAlertWindow granted tapped calls shows warning',
        (WidgetTester tester) async {
      setupPermissions(
          {Permission.systemAlertWindow: PermissionStatus.granted});
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
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
      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byIcon(AbiliaIcons.irError), findsOneWidget);
      expect(find.byType(ErrorMessage), findsOneWidget);
      expect(find.text(translate.notificationsWarningHintText), findsOneWidget);
    });

    testWidgets(
        'Fullscreen Alarm Info button shows FullscreenAlarmInfoDialog without RequestFullScreenNotificationButton',
        (WidgetTester tester) async {
      setupPermissions({Permission.systemAlertWindow: PermissionStatus.denied});

      await tester.pumpWidget(wrapWithMaterialApp(const MpGoMenuPage()));
      await tester.pumpAndSettle();
      await tester.tap(permissionButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InfoButton));
      await tester.pumpAndSettle();

      expect(find.byType(FullscreenAlarmInfoDialog), findsOneWidget);
      expect(find.byType(RequestFullscreenNotificationButton), findsNothing);
      expect(find.text(translate.notificationsWarningHintText), findsNothing);
    });
  }, skip: Config.isMP);

  testWidgets('Permissions page not available on MP',
      (WidgetTester tester) async {
    setupPermissions({Permission.systemAlertWindow: PermissionStatus.denied});

    await tester.pumpWidget(wrapWithMaterialApp(const SettingsPage()));
    await tester.pumpAndSettle();
    expect(find.byType(PermissionPickField), findsNothing);
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future scrollTo(Finder f, {double dy = -30.0}) async {
    await dragUntilVisible(f, find.byType(PermissionsPage), Offset(0.0, dy));
  }
}
