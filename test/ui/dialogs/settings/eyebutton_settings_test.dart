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

void main() {
  MockSettingsDb mockSettingsDb;
  final translate = Locales.language.values.first;

  setUp(() async {
    setupPermissions();
    final initTime = DateTime(2020, 07, 23, 11, 29);
    ActivityResponse activityResponse = () => [];

    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockTicker = StreamController<DateTime>();
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    final mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
        Future.value([Activity.createNew(title: 'null', startTime: initTime)]));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    mockSettingsDb = MockSettingsDb();
    when(mockSettingsDb.dotsInTimepillar).thenReturn(true);

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker(stream: mockTicker.stream, initialTime: initTime)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client(activityResponse: activityResponse)
      ..fileStorage = MockFileStorage()
      ..userFileDb = MockUserFileDb()
      ..settingsDb = mockSettingsDb
      ..syncDelay = SyncDelays.zero
      ..alarmScheduler = noAlarmScheduler
      ..database = MockDatabase()
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('Timepillar shows first dots, then edge when settings changes',
      (WidgetTester tester) async {
    // Act - go to timepillar
    await tester.goToEyeButtonSettings();
    await tester.tap(find.byIcon(AbiliaIcons.timeline));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.ok));
    await tester.pumpAndSettle();

    // Assert - At timepillar and side dots shows
    expect(find.byType(TimePillarCalendar), findsOneWidget);
    expect(find.byType(SideDots), findsWidgets);
    expect(find.byType(SideTime), findsNothing);

    // Act - change to Edge illustraion in time
    await tester.tap(find.byType(EyeButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.flarp));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.ok));
    await tester.pumpAndSettle();

    // Assert - At timepillar and side time shows
    expect(find.byType(TimePillarCalendar), findsOneWidget);
    expect(find.byType(SideDots), findsNothing);
    expect(find.byType(SideTime), findsWidgets);
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.goToEyeButtonSettings();

    await tester.verifyTts(find.text(translate.viewMode),
        exact: translate.viewMode);
    await tester.verifyTts(find.byIcon(AbiliaIcons.calendar),
        exact: translate.listView);
    await tester.verifyTts(find.byIcon(AbiliaIcons.timeline),
        exact: translate.timePillarView);
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
    await tap(find.byType(EyeButton));
    await pumpAndSettle();
  }
}
