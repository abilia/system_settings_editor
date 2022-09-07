import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/tts.dart';
import '../../../test_helpers/verify_generic.dart';

void main() {
  final translate = Locales.language.values.first;
  late MockGenericDb mockGenericDb;

  setUp(() async {
    setupPermissions();
    setupFakeTts();
    final initTime = DateTime(2020, 07, 23, 11, 29);

    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    final mockActivityDb = MockActivityDb();
    when(() => mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
        Future.value([Activity.createNew(title: 'null', startTime: initTime)]));
    when(() => mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value([]));
    when(() => mockActivityDb.getAllAfter(any()))
        .thenAnswer((_) => Future.value([]));

    final timepillarGeneric = Generic.createNew<MemoplannerSettingData>(
      data: MemoplannerSettingData.fromData(
          data: DayCalendarType.oneTimepillar.index,
          identifier: MemoplannerSettings.viewOptionsTimeViewKey),
    );

    mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value([timepillarGeneric]));
    when(() => mockGenericDb.getLastRevision())
        .thenAnswer((_) => Future.value(0));
    when(() => mockGenericDb.getById(any()))
        .thenAnswer((_) => Future.value(null));
    when(() => mockGenericDb.insert(any())).thenAnswer((_) async {});
    when(() => mockGenericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker.fake(initialTime: initTime)
      ..fireBasePushService = FakeFirebasePushService()
      ..client = Fakes.client(activityResponse: () => [])
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..genericDb = mockGenericDb
      ..database = FakeDatabase()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('Timepillar shows first edge, then dots when settings changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
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

    verifyUnsyncGeneric(
      tester,
      mockGenericDb,
      key: MemoplannerSettings.dotsInTimepillarKey,
      matcher: isTrue,
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
    if (pumpApp) await pumpWidget(App());
    await pumpAndSettle();
    await tap(find.byType(EyeButtonDay));
    await pumpAndSettle();
  }
}
