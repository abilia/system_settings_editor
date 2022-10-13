import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/background/all.dart';

import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  final time = DateTime(2022, 05, 10, 13, 37);
  Iterable<Session> sessions;
  const mp4Session = Session(type: 'flutter', app: 'memoplanner');
  const mp3Session = Session(type: 'android', app: 'memoplanner3');
  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;
    sessions = [];

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker.fake(initialTime: time)
      ..client = Fakes.client(sessionsResponse: () => sessions)
      ..database = FakeDatabase()
      ..genericDb = FakeGenericDb()
      ..sortableDb = FakeSortableDb()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('Mp go menu page', () {
    setUp(() {});

    testWidgets('Has menu icon when MP4 session is available', (tester) async {
      sessions = [mp4Session];
      await tester.pumpApp();
      expect(find.byIcon(AbiliaIcons.menu), findsOneWidget);
    });

    testWidgets('Displays my photos pick field when MP4 session is available',
        (tester) async {
      sessions = [mp4Session];
      await tester.pumpApp();
      await tester.tap(find.byType(MpGoMenuButton));
      await tester.pumpAndSettle();
      expect(find.byType(MyPhotosPickField), findsOneWidget);
    });

    testWidgets('Has settings icon when no MP4 session is available',
        (tester) async {
      sessions = [mp3Session];
      await tester.pumpApp();
      expect(find.byIcon(AbiliaIcons.settings), findsOneWidget);
    });

    testWidgets('No my photos when only mp3 session', (tester) async {
      sessions = [mp3Session];
      await tester.pumpApp();
      await tester.tap(find.byType(MpGoMenuButton));
      await tester.pumpAndSettle();
      expect(find.byType(MyPhotosPickField), findsNothing);
    });
  }, skip: !Config.isMPGO);
}