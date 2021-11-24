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
import '../../../test_helpers/app_pumper.dart';

void main() {
  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
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
      ..sortableDb = FakeSortableDb()
      ..battery = FakeBattery()
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('My photos page', () {
    testWidgets('The page shows', (tester) async {
      await tester.goToMyPhotos();
      expect(find.byType(MyPhotosPage), findsOneWidget);
    });

    testWidgets('Can navigate back to menu', (tester) async {
      await tester.goToMyPhotos();
      expect(find.byType(MyPhotosPage), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> goToMyPhotos() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.myPhotos));
    await pumpAndSettle();
  }
}
