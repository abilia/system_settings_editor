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
import 'package:seagull/ui/pages/settings/calendar/add_activity/new_activity_general_settings_tab.dart';

import '../../../../../mocks.dart';
import '../../../../../utils/verify_generic.dart';

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

  group('New activity settings page', () {
    testWidgets('Navigate to page', (tester) async {
      await tester.goToNewActivitySettingsPage(pump: true);
      expect(find.byType(NewActivitySettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    testWidgets('Allow passed start time', (tester) async {
      await tester.goToNewActivitySettingsPage(pump: true);
      await tester.tap(find.text(translate.allowPassedStartTime));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.activityTimeBeforeCurrentKey,
        matcher: isFalse,
      );
    });

    testWidgets('Add recurring activity', (tester) async {
      await tester.goToNewActivitySettingsPage(pump: true);
      await tester.tap(find.text(translate.addRecurringActivity));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.activityRecurringEditableKey,
        matcher: isFalse,
      );
    });

    testWidgets('Show end time', (tester) async {
      await tester.goToNewActivitySettingsPage(pump: true);
      await tester.tap(find.text(translate.showEndTime));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.activityEndTimeEditableKey,
        matcher: isFalse,
      );
    });

    testWidgets('show alarm', (tester) async {
      await tester.goToNewActivitySettingsPage(pump: true);
      await tester.tap(find.text(translate.showAlarm));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.activityDisplayAlarmOptionKey,
        matcher: isFalse,
      );
    });

    testWidgets('Show silent alarm', (tester) async {
      await tester.goToNewActivitySettingsPage(pump: true);
      await tester.tap(find.text(translate.showSilentAlarm));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.activityDisplaySilentAlarmOptionKey,
        matcher: isFalse,
      );
    });

    testWidgets('Show no alarm', (tester) async {
      await tester.goToNewActivitySettingsPage(pump: true);
      await tester.dragUntilVisible(find.text(translate.showNoAlarm),
          find.byType(NewActivityGeneralSettingsTab), Offset(0, 100));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.showNoAlarm));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.activityDisplayNoAlarmOptionKey,
        matcher: isFalse,
      );
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToNewActivitySettingsPage({bool pump = false}) async {
    if (pump) await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.new_icon));
    await pumpAndSettle();
  }
}
