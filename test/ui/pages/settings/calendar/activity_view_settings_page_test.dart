import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../../mocks/shared.dart';
import '../../../../mocks/shared.mocks.dart';
import '../../../../test_helpers/app_pumper.dart';
import '../../../../test_helpers/alarm_schedualer.dart';
import '../../../../test_helpers/fake_shared_preferences.dart';
import '../../../../test_helpers/permission.dart';
import '../../../../test_helpers/verify_generic.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 05, 04, 19, 20);
  Iterable<Generic> generics = [];
  Iterable<Activity> activities = [];
  late MockGenericDb genericDb;
  late MockActivityDb activityDb;

  setUp(() async {
    setupPermissions();
    generics = [];
    activities = [];
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    genericDb = MockGenericDb();
    when(genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(genericDb.insertAndAddDirty(any))
        .thenAnswer((_) => Future.value(true));

    activityDb = MockActivityDb();
    when(activityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activities));
    when(activityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(activityDb.insertAndAddDirty(any))
        .thenAnswer((_) => Future.value(true));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: initialTime,
      )
      ..client = Fakes.client(
        genericResponse: () => generics,
        activityResponse: () => activities,
      )
      ..database = FakeDatabase()
      ..syncDelay = SyncDelays.zero
      ..genericDb = genericDb
      ..activityDb = activityDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('activity view settings page', () {
    testWidgets('defaults', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byType(ActivityViewSettingsPage), findsOneWidget);
      expect(find.byType(ActivityPagePreview), findsOneWidget);
      final switches = tester.widgetList<SwitchField>(find.byType(SwitchField));
      for (final s in switches) {
        expect(s.value, isTrue);
      }
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
      expect(find.byKey(TestKey.editAlarm), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.delete_all_clear), findsNWidgets(2));
      expect(find.byIcon(AbiliaIcons.edit), findsNWidgets(2));
      expect(find.byType(ActivityInfoSideDots), findsOneWidget);
      expect(find.byKey(TestKey.sideDotsTimeText), findsOneWidget);
    });

    testWidgets('respects memoSettings ', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayAlarmButtonKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayDeleteButtonKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayEditButtonKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayQuarterHourKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayTimeLeftKey,
          ),
        ),
      ];

      await tester.goToActivityViewSettingsPage();
      expect(find.byType(ActivityViewSettingsPage), findsOneWidget);
      expect(find.byType(ActivityPagePreview), findsOneWidget);
      final switches = tester.widgetList<SwitchField>(find.byType(SwitchField));
      for (final s in switches) {
        expect(s.value, isFalse);
      }
      expect(find.byKey(TestKey.editAlarm), findsNothing);
      expect(find.byIcon(AbiliaIcons.delete_all_clear), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.edit), findsOneWidget);
      expect(find.byType(ActivityInfoSideDots), findsNothing);
      expect(find.byKey(TestKey.sideDotsTimeText), findsNothing);
    });

    testWidgets('hide alarm button saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byKey(TestKey.editAlarm), findsOneWidget);
      await tester.tap(find.text(translate.alarm));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.editAlarm), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.displayAlarmButtonKey,
        matcher: isFalse,
      );
    });

    testWidgets('hide delete button saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byIcon(AbiliaIcons.delete_all_clear), findsNWidgets(2));
      await tester.tap(find.text(translate.delete));
      await tester.pumpAndSettle();
      expect(find.byIcon(AbiliaIcons.delete_all_clear), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.displayDeleteButtonKey,
        matcher: isFalse,
      );
    });

    testWidgets('hide edit button saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byIcon(AbiliaIcons.edit), findsNWidgets(2));
      await tester.dragUntilVisible(
        find.text(translate.edit),
        find.byType(ActivityViewSettingsPage),
        Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.edit));
      await tester.pumpAndSettle();
      expect(find.byIcon(AbiliaIcons.edit), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.displayEditButtonKey,
        matcher: isFalse,
      );
    });

    testWidgets('hide display quarter hour bar saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byType(ActivityInfoSideDots), findsOneWidget);
      await tester.dragUntilVisible(
        find.byIcon(AbiliaIcons.timeline),
        find.byType(ActivityViewSettingsPage),
        Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.timeline));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityInfoSideDots), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.displayQuarterHourKey,
        matcher: isFalse,
      );
    });

    testWidgets('hide time under quarter hour bar saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byKey(TestKey.sideDotsTimeText), findsOneWidget);
      await tester.dragUntilVisible(
        find.byIcon(AbiliaIcons.timeline),
        find.byType(ActivityViewSettingsPage),
        Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.clock));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.sideDotsTimeText), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.displayTimeLeftKey,
        matcher: isFalse,
      );
    });
  }, skip: !Config.isMP);

  group('settings in acivity view', () {
    testWidgets('defaults', (tester) async {
      activities = [
        Activity.createNew(
          title: 'title',
          startTime: initialTime.add(1.hours()),
        )
      ];

      await tester.goToActivityPage();

      expect(find.byKey(TestKey.editAlarm), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.delete_all_clear), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.edit), findsOneWidget);
      expect(find.byType(ActivityInfoSideDots), findsOneWidget);
      expect(find.byKey(TestKey.sideDotsTimeText), findsOneWidget);
    });

    testWidgets('all hidden', (tester) async {
      activities = [
        Activity.createNew(
          title: 'title',
          startTime: initialTime.add(1.hours()),
        )
      ];
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayAlarmButtonKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayDeleteButtonKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayEditButtonKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.displayQuarterHourKey,
          ),
        ),
      ];

      await tester.goToActivityPage();

      expect(find.byKey(TestKey.editAlarm), findsNothing);
      expect(find.byIcon(AbiliaIcons.delete_all_clear), findsNothing);
      expect(find.byIcon(AbiliaIcons.edit), findsNothing);
      expect(find.byType(ActivityInfoSideDots), findsNothing);
      expect(find.byKey(TestKey.sideDotsTimeText), findsNothing);
    });
  });
}

extension on WidgetTester {
  Future<void> goToActivityPage() async {
    await pumpApp();
    await tap(find.byType(ActivityCard));
    await pumpAndSettle();
  }

  Future<void> goToActivityViewSettingsPage() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.full_screen));
    await pumpAndSettle();
  }
}
