import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/select_alarm_duration_page.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Generic> generics = [];
  GenericDb genericDb;

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockBatch = MockBatch();
    when(mockBatch.commit()).thenAnswer((realInvocation) => Future.value([]));
    final db = MockDatabase();
    when(db.batch()).thenReturn(mockBatch);
    when(db.rawQuery(any)).thenAnswer((realInvocation) => Future.value([]));

    genericDb = MockGenericDb();
    when(genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(genericDb.insertAndAddDirty(any))
        .thenAnswer((realInvocation) => Future.value([]));

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: initialTime,
      )
      ..client = Fakes.client(genericResponse: () => generics)
      ..alarmScheduler = noAlarmScheduler
      ..database = db
      ..syncDelay = SyncDelays.zero
      ..genericDb = genericDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  Future _verifySaved(
    WidgetTester tester, {
    String key,
    dynamic matcher,
  }) async {
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    final v = verify(genericDb.insertAndAddDirty(captureAny));
    expect(v.callCount, 1);
    final l = v.captured.single.toList() as List<Generic<GenericData>>;
    final d = l
        .whereType<Generic<MemoplannerSettingData>>()
        .firstWhere((element) => element.data.identifier == key);
    expect(d.data.data, matcher);
  }

  group('Alarm setting spage', () {
    testWidgets('The page shows', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      expect(find.byType(AlarmSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    testWidgets('Select non checkable alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      expect(find.text(Sound.Default.displayName(null)), findsNWidgets(3));
      expect(find.text(Sound.Drum.displayName(null)), findsNothing);
      await tester.tap(find.byKey(TestKey.nonCheckableAlarmSelector));
      await tester.pumpAndSettle();
      expect(find.byType(SelectSoundPage), findsOneWidget);
      await tester.tap(find.text(Sound.Drum.displayName(null)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.text(Sound.Default.displayName(null)), findsNWidgets(2));
      expect(find.text(Sound.Drum.displayName(null)), findsOneWidget);
      await _verifySaved(
        tester,
        key: MemoplannerSettings.nonCheckableActivityAlarmKey,
        matcher: Sound.Drum.name(),
      );
    });

    testWidgets('Select checkable alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      await tester.tap(find.byKey(TestKey.checkableAlarmSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Sound.Trip.displayName(null)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await _verifySaved(
        tester,
        key: MemoplannerSettings.checkableActivityAlarmKey,
        matcher: Sound.Trip.name(),
      );
    });

    testWidgets('Select reminder alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      await tester.tap(find.byKey(TestKey.reminderAlarmSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Sound.Springboard.displayName(null)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await _verifySaved(
        tester,
        key: MemoplannerSettings.reminderAlarmKey,
        matcher: Sound.Springboard.name(),
      );
    });

    testWidgets('Select alarm duration', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      await tester.tap(find.byKey(TestKey.alarmDurationSelector));
      await tester.pumpAndSettle();
      expect(find.byType(SelectAlarmDurationPage), findsOneWidget);
      await tester
          .tap(find.text(AlarmDuration.FiveMinutes.displayText(translate)));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await _verifySaved(
        tester,
        key: MemoplannerSettings.alarmDurationKey,
        matcher: 5.minutes().inMilliseconds,
      );
    });

    testWidgets('Select vibrate at reminder', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      await tester.tap(find.byKey(TestKey.vibrateAtReminderSelector));
      await tester.pumpAndSettle();
      await _verifySaved(
        tester,
        key: MemoplannerSettings.vibrateAtReminderKey,
        matcher: false,
      );
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToAlarmSettingsPage({bool pump = false}) async {
    if (pump) await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.handi_alarm_vibration));
    await pumpAndSettle();
  }
}
