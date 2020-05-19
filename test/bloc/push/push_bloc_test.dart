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
    final fakeUrl = 'SomeUrl';

    setUp(() {
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));

      final dbActivityAnswers = [
        <Activity>[],
        [FakeActivity.startsNow(1.hours())]
      ];
      final serverActivityAnswers = [
        <Activity>[],
        [FakeActivity.startsNow(1.hours())]
      ];

      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(0));
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(dbActivityAnswers.removeAt(0)));

      GetItInitializer()
        ..tokenDb = mockTokenDb
        ..activityDb = mockActivityDb
        ..httpClient = Fakes.client(() => serverActivityAnswers.removeAt(0))
        ..userDb = MockUserDb()
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = MockFirebasePushService()
        ..ticker = Ticker(stream: StreamController<DateTime>().stream)
        ..init();
    });

    testWidgets('Push loads activities', (WidgetTester tester) async {
      final pushBloc = PushBloc();

      await tester.pumpWidget(App(
        baseUrl: fakeUrl,
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
