import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../mocks.dart';

void main() {
  group('Activity page test', () {
    MockActivityDb mockActivityDb;
    StreamController<DateTime> mockTicker;
    final activityBackButtonFinder = find.byKey(TestKey.activityBackButton);
    ActivityResponse activityResponse = () => [];
    setUp(() {
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      mockTicker = StreamController<DateTime>();
      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      mockActivityDb = MockActivityDb();
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = (() => mockTicker.stream)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(activityResponse)
        ..init();
    });

    testWidgets('Navigate to activity page and back', (WidgetTester tester) async {
      when(mockActivityDb.getActivities())
          .thenAnswer((_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
      await tester.tap(find.byType(ActivityCard));
      await tester.pumpAndSettle();
      expect(activityBackButtonFinder, findsOneWidget);
      await tester.tap(activityBackButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });
  });
}
