import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_clock/ticker.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/verify_generic_mp.dart';

void main() {
  group('Alarm settings page', () {
    late final Lt translate;
    final initialTime = DateTime(2021, 04, 17, 09, 20);
    Iterable<Generic> generics = [];
    Iterable<Activity> activities = [];
    late MockGenericDb genericDb;
    late ActivityDbInMemory activityDb;
    Iterable<Session> sessions;

    setUpAll(() async {
      await Lokalise.initMock();
      translate = await Lt.load(Lt.supportedLocales.first);
    });

    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
      scheduleNotificationsIsolated = noAlarmScheduler;
      sessions = fakeSessions;

      genericDb = MockGenericDb();
      when(() => genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(generics));
      when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      when(() => genericDb.insertAndAddDirty(any()))
          .thenAnswer((_) => Future.value(true));
      when(() => genericDb.getById(any()))
          .thenAnswer((_) => Future.value(null));
      when(() => genericDb.insert(any())).thenAnswer((_) async {});

      activityDb = ActivityDbInMemory()..initWithActivities(activities);

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker.fake(initialTime: initialTime)
        ..client = fakeClient(sessionsResponse: () => sessions)
        ..database = FakeDatabase()
        ..sortableDb = FakeSortableDb()
        ..genericDb = genericDb
        ..activityDb = activityDb
        ..battery = FakeBattery()
        ..deviceDb = FakeDeviceDb()
        ..init();
    });

    tearDown(() {
      GetIt.I.reset();
      generics = [];
      activities = [];
    });

    testWidgets('The page shows', (tester) async {
      await tester.goToAlarmSettingsPage();
      expect(find.byType(AlarmSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    testWidgets('BUG SGC-1564 Has ScrollArrows', (tester) async {
      await tester.goToAlarmSettingsPage();
      expect(find.byType(ScrollArrows), findsOneWidget);
    });

    testWidgets('Select non checkable alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage();
      expect(find.text(Sound.Default.displayName(translate)), findsNWidgets(4));
      expect(find.text(Sound.AfloatSynth.displayName(translate)), findsNothing);
      await tester.tap(find.byKey(TestKey.nonCheckableAlarmSelector));
      await tester.pumpAndSettle();
      expect(find.byType(SelectSoundPage), findsOneWidget);
      await tester.tap(find.text(Sound.AfloatSynth.displayName(translate)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.text(Sound.Default.displayName(translate)), findsNWidgets(3));
      expect(
          find.text(Sound.AfloatSynth.displayName(translate)), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifyUnsyncedGenericMP(
        tester,
        genericDb,
        key: AlarmSettings.nonCheckableActivityAlarmKey,
        matcher: Sound.AfloatSynth.name,
      );
    });

    testWidgets('Select checkable alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage();
      await tester.tap(find.byKey(TestKey.checkableAlarmSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Sound.BreathlessPiano.displayName(translate)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifyUnsyncedGenericMP(
        tester,
        genericDb,
        key: AlarmSettings.checkableActivityAlarmKey,
        matcher: Sound.BreathlessPiano.name,
      );
    });

    testWidgets('Select reminder alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage();
      await tester.tap(find.byKey(TestKey.reminderAlarmSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Sound.GibsonGuitar.displayName(translate)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifyUnsyncedGenericMP(
        tester,
        genericDb,
        key: AlarmSettings.reminderAlarmKey,
        matcher: Sound.GibsonGuitar.name,
      );
    });

    testWidgets('Select timer alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage();
      await tester.scrollDown();
      await tester.tap(find.byKey(TestKey.timerAlarmSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Sound.DoorBell.displayName(translate)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifyUnsyncedGenericMP(
        tester,
        genericDb,
        key: AlarmSettings.timerAlarmKey,
        matcher: Sound.DoorBell.name,
      );
    });

    testWidgets('Select alarm duration', (tester) async {
      await tester.goToAlarmSettingsPage();
      await tester.scrollDown();
      await tester.tap(find.byKey(TestKey.alarmDurationSelector));
      await tester.pumpAndSettle();
      expect(find.byType(SelectAlarmDurationPage), findsOneWidget);
      expect(find.byType(ErrorMessage), findsNothing);
      await tester
          .tap(find.text(AlarmDuration.fiveMinutes.displayText(translate)));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorMessage), findsOneWidget);
      expect(find.text(translate.iOSAlarmTimeWarning), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifyUnsyncedGenericMP(
        tester,
        genericDb,
        key: AlarmSettings.alarmDurationKey,
        matcher: 5.minutes().inMilliseconds,
      );
    });

    testWidgets('Display switch for alarms', (tester) async {
      await tester.goToAlarmSettingsPage();
      await tester.scrollDown();
      await tester.tap(find.byKey(TestKey.showAlarmOnOffSwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifyUnsyncedGenericMP(
        tester,
        genericDb,
        key: AlarmSettings.showAlarmOnOffSwitchKey,
        matcher: true,
      );
    });

    testWidgets('Switch for ongoing activity in full screen', (tester) async {
      await tester.goToAlarmSettingsPage();
      await tester.scrollDown();
      await tester.tap(find.byKey(TestKey.showOngoingActivityInFullScreen));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifyUnsyncedGenericMP(
        tester,
        genericDb,
        key: AlarmSettings.showOngoingActivityInFullScreenKey,
        matcher: true,
      );
    }, skip: Config.isMPGO);

    testWidgets('Changes to alarm triggers an alarm scheduling',
        (tester) async {
      activities = [Activity.createNew(startTime: initialTime.add(1.hours()))];
      await tester.goToAlarmSettingsPage();
      await tester.scrollDown();
      await tester.tap(find.byKey(TestKey.alarmDurationSelector));
      await tester.pumpAndSettle();
      await tester
          .tap(find.text(AlarmDuration.fiveMinutes.displayText(translate)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      final preCalls = scheduleNotificationsCalls;
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(scheduleNotificationsCalls, greaterThanOrEqualTo(preCalls + 1));
    });

    testWidgets('No changes to alarm triggers no alarm scheduling',
        (tester) async {
      await tester.goToAlarmSettingsPage();
      final preCalls = scheduleNotificationsCalls;
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(scheduleNotificationsCalls, preCalls);
    });

    testWidgets(
        'SGC-1347 Fullscreen activity setting should only be visible on MP',
        (tester) async {
      await tester.goToAlarmSettingsPage();
      expect(find.byType(AlarmSettingsPage), findsOneWidget);
      if (Config.isMP) {
        expect(find.byKey(TestKey.showOngoingActivityInFullScreen),
            findsOneWidget);
      }
      if (Config.isMPGO) {
        expect(
            find.byKey(TestKey.showOngoingActivityInFullScreen), findsNothing);
      }
    });

    testWidgets('SGC-2158 - If session is MP4, show alarm settings for timers',
        (tester) async {
      sessions = [Session.mp4Session()];
      await tester.goToAlarmSettingsPage();
      expect(find.text('Timer'), findsOneWidget);
    });

    testWidgets(
        'SGC-2158 - If session is MP3, show no alarm settings for timers',
        (tester) async {
      sessions = [Session.mp3Session()];
      await tester.goToAlarmSettingsPage();
      expect(find.text('Timer'), findsNothing);
    });
  });
}

extension on WidgetTester {
  Future<void> goToAlarmSettingsPage() async {
    await pumpApp();

    if (Config.isMP) {
      await tap(find.byType(MenuButton));
      await pumpAndSettle();
      await tap(find.byType(SettingsButton));
      await pumpAndSettle();
      await tap(find.byIcon(AbiliaIcons.month));
      await pumpAndSettle();
    }

    if (Config.isMPGO) {
      await tap(find.byType(MpGoMenuButton));
      await pumpAndSettle();
    }

    await tap(find.byIcon(AbiliaIcons.handiAlarmVibration));
    await pumpAndSettle();
  }

  Future scrollDown({double dy = -800.0}) async {
    final center = getCenter(find.byType(AlarmSettingsPage));
    await dragFrom(center, Offset(0.0, dy));
    await pump();
  }
}
