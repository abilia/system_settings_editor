import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/tts.dart';

void main() {
  late final Lt translate;

  late SharedPreferences fakeSharedPreferences;

  setUpAll(() async {
    translate = await Lt.load(Lt.supportedLocales.first);
  });

  setUp(() async {
    setupPermissions();
    setupFakeTts();
    final initTime = DateTime(2020, 07, 23, 11, 29);

    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;

    final mockActivityDb = ActivityDbInMemory()
      ..initWithActivity(
          Activity.createNew(title: 'null', startTime: initTime));
    fakeSharedPreferences = await FakeSharedPreferences.getInstance(
      extras: {
        DayCalendarViewSettings.viewOptionsCalendarTypeKey:
            DayCalendarType.oneTimepillar.index
      },
    );

    GetItInitializer()
      ..sharedPreferences = fakeSharedPreferences
      ..activityDb = mockActivityDb
      ..sortableDb = FakeSortableDb()
      ..ticker = Ticker.fake(initialTime: initTime)
      ..fireBasePushService = FakeFirebasePushService()
      ..client = fakeClient(activityResponse: () => [])
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..database = FakeDatabase()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('Timepillar shows first edge, then dots when settings changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Assert - At timepillar and edge shows
    expect(find.byType(TimepillarCalendar), findsOneWidget);
    expect(find.byType(SideTime), findsWidgets);
    expect(find.byType(SideDots), findsNothing);

    // Act - change to side dots illustration in time
    await tester.pumpAndSettle();
    await tester.tap(find.byType(EyeButtonDay));
    await tester.pumpAndSettle();
    final center = tester.getCenter(find.byType(EyeButtonDayDialog));
    await tester.dragFrom(center, const Offset(0.0, -400));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(AbiliaIcons.options));
    await tester.pumpAndSettle();

    expect(find.byType(OkButton), findsOneWidget);

    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    expect(
      fakeSharedPreferences.getBool(DayCalendarViewSettings.viewOptionsDotsKey),
      isTrue,
    );
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.goToEyeButtonSettings();

    await tester.tap(find.byIcon(AbiliaIcons.timeline));
    await tester.pumpAndSettle();

    // Verify correct TTS timeline
    await tester.verifyTts(find.text(translate.viewMode),
        exact: translate.viewMode);
    await tester.verifyTts(find.byIcon(AbiliaIcons.calendarList),
        exact: translate.listView);
    await tester.verifyTts(find.byIcon(AbiliaIcons.timeline),
        exact: translate.oneTimePillarView);
    await tester.verifyTts(find.byIcon(AbiliaIcons.twoTimelines),
        exact: translate.twoTimePillarsView);

    // Verify correct TTS zoom. Small and medium has same icon for now
    await tester.verifyTts(find.text(translate.timelineZoom),
        exact: translate.timelineZoom);
    await tester.verifyTts(find.text(translate.small), exact: translate.small);
    await tester.verifyTts(find.text(translate.medium),
        exact: translate.medium);
    await tester.verifyTts(find.byIcon(AbiliaIcons.enlargeText),
        exact: translate.large);

    // Verify correct TTS intervals
    await tester.verifyTts(find.text(translate.dayInterval),
        exact: translate.dayInterval);
    await tester.verifyTts(find.byIcon(AbiliaIcons.dayInterval),
        exact: translate.interval);
    await tester.verifyTts(find.byIcon(AbiliaIcons.sun),
        exact: translate.viewDay);
    await tester.verifyTts(find.byIcon(AbiliaIcons.dayNight),
        exact: translate.dayAndNight);

    // Scroll down
    final center = tester.getCenter(find.byType(EyeButtonDayDialog));
    await tester.dragFrom(center, const Offset(0.0, -400));
    await tester.pumpAndSettle();

    // Verify correct TTS for duration setting
    await tester.verifyTts(find.text(translate.activityDuration),
        exact: translate.activityDuration);
    await tester.verifyTts(find.byIcon(AbiliaIcons.options),
        exact: translate.dots);
    await tester.verifyTts(find.byIcon(AbiliaIcons.flarp),
        exact: translate.edge);
  });
}

extension on WidgetTester {
  Future<void> goToEyeButtonSettings({bool pumpApp = true}) async {
    if (pumpApp) await pumpWidget(const App());
    await pumpAndSettle();
    await tap(find.byType(EyeButtonDay));
    await pumpAndSettle();
  }
}
