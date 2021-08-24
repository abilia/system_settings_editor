// @dart=2.9

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';

void main() {
  group('Photo calendar page', () {
    final initialTime = DateTime(2021, 04, 17, 09, 20);

    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
      scheduleAlarmNotificationsIsolated = noAlarmScheduler;

      final mockBatch = MockBatch();
      when(mockBatch.commit()).thenAnswer((realInvocation) => Future.value([]));
      final db = MockDatabase();
      when(db.batch()).thenReturn(mockBatch);

      GetItInitializer()
        ..sharedPreferences = await MockSharedPreferences.getInstance()
        ..ticker = Ticker(
          stream: StreamController<DateTime>().stream,
          initialTime: initialTime,
        )
        ..client = Fakes.client()
        ..database = db
        ..syncDelay = SyncDelays.zero
        ..genericDb = MockGenericDb()
        ..init();
    });

    tearDown(GetIt.I.reset);

    testWidgets('The page shows', (tester) async {
      await tester.goToPhotoCalendarPage(pump: true);
      expect(find.byType(PhotoCalendarPage), findsOneWidget);
    });

    testWidgets('Can navigate back to calendar', (tester) async {
      await tester.goToPhotoCalendarPage(pump: true);
      expect(find.byType(PhotoCalendarPage), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> goToPhotoCalendarPage({bool pump = false}) async {
    if (pump) await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(PhotoCalendarButton));
    await pumpAndSettle();
  }
}
