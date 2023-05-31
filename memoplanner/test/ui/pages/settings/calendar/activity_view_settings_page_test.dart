import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:seagull_fakes/all.dart';

import '../../../../fakes/activity_db_in_memory.dart';
import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/app_pumper.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 05, 04, 19, 20);
  Iterable<Generic> generics = [];
  late MockGenericDb genericDb;
  late ActivityDbInMemory activityDb;

  setUp(() async {
    setupPermissions();
    generics = [];
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;

    genericDb = MockGenericDb();
    when(() => genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => genericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    activityDb = ActivityDbInMemory();

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker.fake(initialTime: initialTime)
      ..client = Fakes.client(
        genericResponse: () => generics,
        activityResponse: () => [],
      )
      ..sortableDb = FakeSortableDb()
      ..database = FakeDatabase()
      ..genericDb = genericDb
      ..activityDb = activityDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
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
      expect(find.byIcon(AbiliaIcons.deleteAllClear), findsNWidgets(2));
      expect(find.byIcon(AbiliaIcons.edit), findsNWidgets(2));
      expect(find.byType(ActivityInfoSideDots), findsOneWidget);
      expect(find.byKey(TestKey.sideDotsTimeText), findsOneWidget);
    });

    testWidgets('respects memoSettings ', (tester) async {
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayAlarmButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayDeleteButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayEditButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayQuarterHourKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayTimeLeftKey,
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
      expect(find.byIcon(AbiliaIcons.deleteAllClear), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.edit), findsOneWidget);
      expect(find.byType(ActivityInfoSideDots), findsNothing);
      expect(find.byKey(TestKey.sideDotsTimeText), findsNothing);
    });

    testWidgets('respects memoSettings with different values ', (tester) async {
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: ActivityViewSettings.displayAlarmButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayDeleteButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayEditButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: ActivityViewSettings.displayQuarterHourKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayTimeLeftKey,
          ),
        ),
      ];

      await tester.goToActivityViewSettingsPage();
      expect(find.byType(ActivityViewSettingsPage), findsOneWidget);
      expect(find.byType(ActivityPagePreview), findsOneWidget);
      final alarmSwitch = tester
          .widget<SwitchField>(find.byKey(TestKey.activityViewAlarmSwitch));
      expect(alarmSwitch.value, true);
      final removeSwitch = tester
          .widget<SwitchField>(find.byKey(TestKey.activityViewRemoveSwitch));
      expect(removeSwitch.value, false);
      final editSwitch = tester
          .widget<SwitchField>(find.byKey(TestKey.activityViewEditSwitch));
      expect(editSwitch.value, false);
    });

    testWidgets('hide alarm button saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byKey(TestKey.editAlarm), findsOneWidget);
      await tester.tap(find.text(translate.alarm).last);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.editAlarm), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: ActivityViewSettings.displayAlarmButtonKey,
        matcher: isFalse,
      );
    });

    testWidgets('hide delete button saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byIcon(AbiliaIcons.deleteAllClear), findsNWidgets(2));
      await tester.tap(find.text(translate.delete).last);
      await tester.pumpAndSettle();
      expect(find.byIcon(AbiliaIcons.deleteAllClear), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: ActivityViewSettings.displayDeleteButtonKey,
        matcher: isFalse,
      );
    });

    testWidgets('hide edit button saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byIcon(AbiliaIcons.edit), findsNWidgets(2));
      await tester.dragUntilVisible(
        find.text(translate.edit).last,
        find.byType(ActivityViewSettingsPage),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.edit).last);
      await tester.pumpAndSettle();
      expect(find.byIcon(AbiliaIcons.edit), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: ActivityViewSettings.displayEditButtonKey,
        matcher: isFalse,
      );
    });

    testWidgets('hide display quarter hour bar saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byType(ActivityInfoSideDots), findsOneWidget);
      await tester.dragUntilVisible(
        find.byIcon(AbiliaIcons.timeline),
        find.byType(ActivityViewSettingsPage),
        const Offset(0, -100),
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
        key: ActivityViewSettings.displayQuarterHourKey,
        matcher: isFalse,
      );
    });

    testWidgets('hide time under quarter hour bar saved', (tester) async {
      await tester.goToActivityViewSettingsPage();
      expect(find.byKey(TestKey.sideDotsTimeText), findsOneWidget);
      await tester.dragUntilVisible(
        find.byIcon(AbiliaIcons.timeline),
        find.byType(ActivityViewSettingsPage),
        const Offset(0, -100),
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
        key: ActivityViewSettings.displayTimeLeftKey,
        matcher: isFalse,
      );
    });
  }, skip: !Config.isMP);

  group('settings in acivity view', () {
    testWidgets('defaults', (tester) async {
      final activities = [
        Activity.createNew(
          title: 'title',
          startTime: initialTime.add(1.hours()),
        )
      ];
      activityDb.initWithActivities(activities);

      await tester.goToActivityPage();

      expect(find.byKey(TestKey.editAlarm), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.deleteAllClear), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.edit), findsOneWidget);
      expect(find.byType(ActivityInfoSideDots), findsOneWidget);
      expect(find.byKey(TestKey.sideDotsTimeText), findsOneWidget);
    });

    testWidgets('all hidden', (tester) async {
      final activities = [
        Activity.createNew(
          title: 'title',
          startTime: initialTime.add(1.hours()),
        )
      ];
      activityDb.initWithActivities(activities);
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayAlarmButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayDeleteButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayEditButtonKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: ActivityViewSettings.displayQuarterHourKey,
          ),
        ),
      ];

      await tester.goToActivityPage();

      expect(find.byKey(TestKey.editAlarm), findsNothing);
      expect(find.byIcon(AbiliaIcons.deleteAllClear), findsNothing);
      expect(find.byIcon(AbiliaIcons.edit), findsNothing);
      expect(find.byType(ActivityInfoSideDots), findsNothing);
      expect(find.byKey(TestKey.sideDotsTimeText), findsNothing);
    });
  });
}

extension on WidgetTester {
  Future<void> goToActivityPage() async {
    await pumpApp();
    await tap(find.byType(ActivityTimepillarCard));
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
    await tap(find.byIcon(AbiliaIcons.fullScreen));
    await pumpAndSettle();
  }
}
