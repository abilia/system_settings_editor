import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../../../mocks.dart';

void main() {
  MockSettingsDb mockSettingsDb;
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  final translate = Locales.language.values.first;

  setUp(() {
    final initTime = DateTime(2020, 07, 23, 11, 29);
    ActivityResponse activityResponse = () => [];

    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockTicker = StreamController<DateTime>();
    final mockTokenDb = MockTokenDb();
    when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    final mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
        Future.value([Activity.createNew(title: 'null', startTime: initTime)]));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    mockSettingsDb = MockSettingsDb();
    when(mockSettingsDb.getDotsInTimepillar()).thenReturn(true);

    GetItInitializer()
      ..activityDb = mockActivityDb
      ..userDb = MockUserDb()
      ..ticker = Ticker(stream: mockTicker.stream, initialTime: initTime)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..tokenDb = mockTokenDb
      ..httpClient = Fakes.client(activityResponse)
      ..fileStorage = MockFileStorage()
      ..userFileDb = MockUserFileDb()
      ..settingsDb = mockSettingsDb
      ..syncDelay = SyncDelays.zero
      ..alarmScheduler = noAlarmScheduler
      ..database = MockDatabase()
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  testWidgets('Settings view for timepillar shows',
      (WidgetTester tester) async {
    await tester.goToTimePillarSettings();
    expect(find.byType(TimePillarSettings), findsOneWidget);
  });

  testWidgets('Settings view contains activity duration',
      (WidgetTester tester) async {
    await tester.goToTimePillarSettings();
    expect(find.byIcon(AbiliaIcons.options), findsOneWidget);
  });

  testWidgets('Activity duration shows', (WidgetTester tester) async {
    await tester.goToTimeIllustation();
    expect(find.byType(TimeIllustration), findsOneWidget);
  });

  testWidgets('Dots preview shows', (WidgetTester tester) async {
    // Act - Go to TimeIllustation settings
    await tester.goToTimeIllustation();
    final crossFade =
        tester.widget<AnimatedCrossFade>(find.byKey(TestKey.preview));
    final dotsPreview = tester.widget(find.byKey(TestKey.dotsPreview));
    final edgePreview = tester.widget(find.byKey(TestKey.edgePreview));

    // Assert - that we show the first preview and the first preview is dots
    expect(crossFade.crossFadeState, CrossFadeState.showFirst);
    expect(crossFade.firstChild, dotsPreview);
    expect(crossFade.secondChild, edgePreview);
  });

  testWidgets('Edge preview shows', (WidgetTester tester) async {
    // Arrange - set Edge as default
    when(mockSettingsDb.getDotsInTimepillar()).thenReturn(false);

    // Act - Go to TimeIllustation settings
    await tester.goToTimeIllustation();
    final crossFade =
        tester.widget<AnimatedCrossFade>(find.byKey(TestKey.preview));
    final dotsPreview = tester.widget(find.byKey(TestKey.dotsPreview));
    final edgePreview = tester.widget(find.byKey(TestKey.edgePreview));

    // Assert - that we show the second preview and the second preview is edge
    expect(crossFade.firstChild, dotsPreview);
    expect(crossFade.secondChild, edgePreview);

    expect(crossFade.crossFadeState, CrossFadeState.showSecond);
  });

  testWidgets('Dots preview shows, then edge, when selected',
      (WidgetTester tester) async {
    // Arrange - Some how get overflow issues with this test when Run all tests
    await binding.setSurfaceSize(Size(640, 640));

    // Act - Go to Time Illustation settings
    await tester.goToTimeIllustation();
    final crossFade =
        tester.widget<AnimatedCrossFade>(find.byKey(TestKey.preview));
    final dotsPreview = tester.widget(find.byKey(TestKey.dotsPreview));
    final edgePreview = tester.widget(find.byKey(TestKey.edgePreview));

    // Assert - that we show the first preview and the first preview is dots
    expect(crossFade.firstChild, dotsPreview);
    expect(crossFade.secondChild, edgePreview);
    expect(crossFade.crossFadeState, CrossFadeState.showFirst);

    // Act - Change to edge time view
    await tester.tap(find.byIcon(AbiliaIcons.flarp));
    await tester.pumpAndSettle();

    // Assert - that we show the second preview
    expect(crossFade.crossFadeState, CrossFadeState.showFirst);
  });

  testWidgets('Timepillar shows first dots, then edge when settings changes',
      (WidgetTester tester) async {
    // Act - go to timepillar
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.changeView));
    await tester.pump();
    await tester.tap(find.byKey(TestKey.timePillarButton));
    await tester.pump();

    // Assert - At timepillar and side dots shows
    expect(find.byType(TimePillarCalendar), findsOneWidget);
    expect(find.byType(SideDots), findsWidgets);
    expect(find.byType(SideTime), findsNothing);

    // Act - change to Edge illustraion in time
    await tester.goToTimeIllustation(pumpApp: false);
    await tester.tap(find.byIcon(AbiliaIcons.flarp));
    await tester.pump();
    await tester.tap(find.byKey(TestKey.closeDialog));
    await tester.pump();

    // Assert - At timepillar and side time shows
    expect(find.byType(TimePillarCalendar), findsOneWidget);
    expect(find.byType(SideDots), findsNothing);
    expect(find.byType(SideTime), findsWidgets);
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.goToTimePillarSettings();

    await tester.verifyTts(find.byIcon(AbiliaIcons.options),
        exact: translate.activityDuration);
    await tester.tap(find.byIcon(AbiliaIcons.options));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.byIcon(AbiliaIcons.options),
        exact: translate.dots);
    await tester.verifyTts(find.byIcon(AbiliaIcons.flarp),
        exact: translate.edge);
    await tester.verifyTts(find.text(translate.activityDuration),
        exact: translate.activityDuration);
    await tester.verifyTts(find.text(translate.preview),
        exact: translate.preview);
  });
}

extension on WidgetTester {
  Future<void> goToTimePillarSettings({bool pumpApp = true}) async {
    if (pumpApp) await pumpWidget(App());
    await pumpAndSettle();
    await tap(find.byKey(TestKey.changeView));
    await pump();
    await tap(find.byKey(TestKey.timePillarSettingsButton));
    await pump();
  }

  Future<void> goToTimeIllustation({bool pumpApp = true}) async {
    await goToTimePillarSettings(pumpApp: pumpApp);
    await tap(find.byIcon(AbiliaIcons.options));
    await pump();
  }
}
