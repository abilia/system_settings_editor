import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/push/push_bloc.dart';
import 'package:seagull/bloc/push/push_event.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/components/activity_card.dart';

import '../../mocks.dart';

void main() {
  group('Push integration test', () {
    MockSecureStorage mockSecureStorage;
    MockFirebasePushService mockFirebasePushService;
    MockActivityDb mockActivityDb;

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) => Future.value(Fakes.token));
      mockFirebasePushService = MockFirebasePushService();
      mockActivityDb = MockActivityDb();
    });

    testWidgets('Push loads activities', (WidgetTester tester) async {
      GetItInitializer()
          .withUserDb(MockUserDb())
          .withActivityDb(mockActivityDb)
          .init();
      final activityResponseAnswers = [
        Response(json.encode([]), 200),
        Response(json.encode([FakeActivity.onTime(DateTime.now())]), 200)
      ];

      final activityAnswers = <List<Activity>>[
        <Activity>[],
        [FakeActivity.onTime(DateTime.now())]
      ];
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(activityAnswers.removeAt(0)));
      when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(0));
      final fakeUrl = 'SomeUrl';
      final mockClient = MockClient(fakeUrl);
      mockClient.whenEntityMeSuccess();
      mockClient.whenActivities(activityResponseAnswers);

      final pushBloc = PushBloc();
      await tester.pumpWidget(App(
        httpClient: mockClient,
        baseUrl: fakeUrl,
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
        pushBloc: pushBloc,
      ));

      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);

      pushBloc.add(OnPush());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);

      pushBloc.close();
    });
  });
}
