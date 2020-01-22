import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../mocks.dart';

void main() {
  group('Push integration test', () {
    final fakeUrl = 'SomeUrl';

    setUp(() {
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));

      final activity = FakeActivity.future();
      final activityResponseAnswers = [
        Response(json.encode([]), 200),
        Response(json.encode([activity]), 200),
      ];

      final activityAnswers = [
        <Activity>[],
        [activity]
      ];
      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(0));
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(activityAnswers.removeAt(0)));

      final mockClient = MockClient(fakeUrl);
      mockClient.whenEntityMeSuccess();
      mockClient.whenActivities(activityResponseAnswers);

      GetItInitializer()
          .withTokenDb(mockTokenDb)
          .withActivityDb(mockActivityDb)
          .withHttpClient(mockClient)
          .withUserDb(MockUserDb())
          .withBaseUrlDb(MockBaseUrlDb())
          .withFireBasePushService(MockFirebasePushService())
          .init();
    });

    testWidgets('Push loads activities', (WidgetTester tester) async {
      final pushBloc = PushBloc();

      await tester.pumpWidget(App(
        baseUrl: fakeUrl,
        pushBloc: pushBloc,
      ));

      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);

      pushBloc.add(OnPush());

      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });
  });
}
