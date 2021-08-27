// @dart=2.9

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';
import '../../../test_helpers/verify_generic.dart';

void main() {
  final translate = Locales.language.values.first;
  MockGenericDb mockGenericDb;

  setUp(() async {
    setupPermissions();
    final initTime = DateTime(2020, 07, 23, 11, 29);
    ActivityResponse activityResponse = () => [];

    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    final mockTicker = StreamController<DateTime>();
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    final mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
        Future.value([Activity.createNew(title: 'null', startTime: initTime)]));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    final mockUserFileDb = MockUserFileDb();
    when(
      mockUserFileDb.getMissingFiles(limit: anyNamed('limit')),
    ).thenAnswer(
      (value) => Future.value([]),
    );

    final timepillarGeneric = Generic.createNew<MemoplannerSettingData>(
      data: MemoplannerSettingData.fromData(
          data: DayCalendarType.timepillar.index,
          identifier: MemoplannerSettings.viewOptionsTimeViewKey),
    );

    mockGenericDb = MockGenericDb();
    when(mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value([timepillarGeneric]));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker(stream: mockTicker.stream, initialTime: initTime)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client(activityResponse: activityResponse)
      ..fileStorage = MockFileStorage()
      ..userFileDb = mockUserFileDb
      ..genericDb = mockGenericDb
      ..syncDelay = SyncDelays.zero
      ..database = MockDatabase()
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('Timepillar shows first dots, then edge when settings changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    // Assert - At timepillar and side dots shows
    expect(find.byType(TimepillarCalendar), findsOneWidget);
    expect(find.byType(SideDots), findsWidgets);
    expect(find.byType(SideTime), findsNothing);

    // Act - change to Edge illustraion in time
    await tester.pumpAndSettle();
    await tester.tap(find.byType(EyeButtonDay));
    await tester.pumpAndSettle();
    final center = tester.getCenter(find.byType(EyeButtonDayDialog));
    await tester.dragFrom(center, Offset(0.0, -400));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(AbiliaIcons.flarp));
    await tester.pumpAndSettle();

    expect(find.byType(OkButton), findsOneWidget);

    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    verifyUnsyncGeneric(
      tester,
      mockGenericDb,
      key: MemoplannerSettings.dotsInTimepillarKey,
      matcher: isFalse,
    );
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.goToEyeButtonSettings();

    await tester.tap(find.byIcon(AbiliaIcons.timeline));
    await tester.pumpAndSettle();

    // Verify correct TTS timeline
    await tester.verifyTts(find.text(translate.viewMode),
        exact: translate.viewMode);
    await tester.verifyTts(find.byIcon(AbiliaIcons.calendar_list),
        exact: translate.listView);
    await tester.verifyTts(find.byIcon(AbiliaIcons.timeline),
        exact: translate.timePillarView);

    // Verify correct TTS zoom. Small and medium has same icon for now
    await tester.verifyTts(find.text(translate.zoom), exact: translate.zoom);
    await tester.verifyTts(find.text(translate.small), exact: translate.small);
    await tester.verifyTts(find.text(translate.medium),
        exact: translate.medium);
    await tester.verifyTts(find.byIcon(AbiliaIcons.enlarge_text),
        exact: translate.large);

    // Verify correct TTS intervals
    await tester.verifyTts(find.text(translate.dayInterval),
        exact: translate.dayInterval);
    await tester.verifyTts(find.byIcon(AbiliaIcons.day_interval),
        exact: translate.interval);
    await tester.verifyTts(find.byIcon(AbiliaIcons.sun),
        exact: translate.viewDay);
    await tester.verifyTts(find.byIcon(AbiliaIcons.day_night),
        exact: translate.dayAndNight);

    // Scroll down
    final center = tester.getCenter(find.byType(EyeButtonDayDialog));
    await tester.dragFrom(center, Offset(0.0, -400));
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
