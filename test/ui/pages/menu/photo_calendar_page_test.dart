import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/shared.mocks.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  group('Photo calendar page', () {
    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
      scheduleAlarmNotificationsIsolated = noAlarmScheduler;

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker(
          stream: StreamController<DateTime>().stream,
          initialTime: DateTime(2021, 04, 17, 09, 20),
        )
        ..client = Fakes.client()
        ..database = FakeDatabase()
        ..syncDelay = SyncDelays.zero
        ..genericDb = FakeGenericDb()
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
