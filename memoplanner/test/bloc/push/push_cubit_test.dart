import 'package:flutter_test/flutter_test.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/ui/components/all.dart';

import '../../fakes/activity_db_in_memory.dart';
import '../../fakes/all.dart';
import '../../mocks/mocks.dart';

void main() {
  group('Push integration test', () {
    setUp(() async {
      tz.initializeTimeZones();
      setupPermissions();
      notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
      scheduleNotificationsIsolated = noAlarmScheduler;

      final time = DateTime(2020, 06, 05, 13, 23);

      final serverActivityAnswers = [
        <Activity>[],
        [FakeActivity.starts(time, duration: 1.hours())]
      ];

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..activityDb = ActivityDbInMemory()
        ..client = Fakes.client(
            activityResponse: () => serverActivityAnswers.removeAt(0))
        ..fireBasePushService = MockFirebasePushService()
        ..userFileDb = FakeUserFileDb()
        ..sortableDb = FakeSortableDb()
        ..ticker = Ticker.fake(initialTime: time)
        ..database = FakeDatabase()
        ..deviceDb = FakeDeviceDb()
        ..init();
    });

    testWidgets('Push loads activities', (WidgetTester tester) async {
      final pushCubit = PushCubit();

      await tester.pumpWidget(App(
        pushCubit: pushCubit,
      ));

      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsNothing);

      pushCubit.fakePush();

      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsOneWidget);
    });
  });
}
