// @dart=2.9

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../mocks.dart';

void main() {
  group('Push integration test', () {
    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
      scheduleAlarmNotificationsIsolated = noAlarmScheduler;

      final time = DateTime(2020, 06, 05, 13, 23);

      final dbActivityAnswers = [
        <Activity>[],
        [FakeActivity.starts(time, duration: 1.hours())]
      ];
      final serverActivityAnswers = [
        <Activity>[],
        [FakeActivity.starts(time, duration: 1.hours())]
      ];

      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(0));
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(dbActivityAnswers.removeAt(0)));

      final mockUserFileDb = MockUserFileDb();
      when(mockUserFileDb.getMissingFiles(limit: anyNamed('limit')))
          .thenAnswer((_) => Future.value([]));

      GetItInitializer()
        ..sharedPreferences = await MockSharedPreferences.getInstance()
        ..activityDb = mockActivityDb
        ..client = Fakes.client(
            activityResponse: () => serverActivityAnswers.removeAt(0))
        ..fireBasePushService = MockFirebasePushService()
        ..userFileDb = mockUserFileDb
        ..ticker = Ticker(
            stream: StreamController<DateTime>().stream, initialTime: time)
        ..database = MockDatabase()
        ..init();
    });

    testWidgets('Push loads activities', (WidgetTester tester) async {
      final pushBloc = PushBloc();

      await tester.pumpWidget(App(
        pushBloc: pushBloc,
      ));

      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);

      pushBloc.add(PushEvent('calendar'));

      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });
  });
}
