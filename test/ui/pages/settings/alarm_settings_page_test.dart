// @dart=2.9

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/settings/select_alarm_duration_page.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  group('Alarm setting spage', () {
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
          .thenAnswer((_) => Future.value(true));

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

    testWidgets('The page shows', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      expect(find.byType(AlarmSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    testWidgets('Select non checkable alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      expect(find.text(Sound.Default.displayName(null)), findsNWidgets(3));
      expect(find.text(Sound.AfloatSynth.displayName(null)), findsNothing);
      await tester.tap(find.byKey(TestKey.nonCheckableAlarmSelector));
      await tester.pumpAndSettle();
      expect(find.byType(SelectSoundPage), findsOneWidget);
      await tester.tap(find.text(Sound.AfloatSynth.displayName(null)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.text(Sound.Default.displayName(null)), findsNWidgets(2));
      expect(find.text(Sound.AfloatSynth.displayName(null)), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.nonCheckableActivityAlarmKey,
        matcher: Sound.AfloatSynth.name(),
      );
    });

    testWidgets('Select checkable alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      await tester.tap(find.byKey(TestKey.checkableAlarmSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Sound.BreathlessPiano.displayName(null)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.checkableActivityAlarmKey,
        matcher: Sound.BreathlessPiano.name(),
      );
    });

    testWidgets('Select reminder alarm sound', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      await tester.tap(find.byKey(TestKey.reminderAlarmSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Sound.LatinAcousticGuitar.displayName(null)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.reminderAlarmKey,
        matcher: Sound.LatinAcousticGuitar.name(),
      );
    });

    testWidgets('Select alarm duration', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      await tester.tap(find.byKey(TestKey.alarmDurationSelector));
      await tester.pumpAndSettle();
      expect(find.byType(SelectAlarmDurationPage), findsOneWidget);
      expect(find.byType(ErrorMessage), findsNothing);
      await tester
          .tap(find.text(AlarmDuration.FiveMinutes.displayText(translate)));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorMessage), findsOneWidget);
      expect(find.text(translate.iOSAlarmTimeWarning), findsOneWidget);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.alarmDurationKey,
        matcher: 5.minutes().inMilliseconds,
      );
    });

    testWidgets('Select vibrate at reminder', (tester) async {
      await tester.goToAlarmSettingsPage(pump: true);
      await tester.tap(find.byKey(TestKey.vibrateAtReminderSelector));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.vibrateAtReminderKey,
        matcher: false,
      );
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
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
