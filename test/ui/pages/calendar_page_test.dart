import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/main.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';

import '../../mocks.dart';

void main() {
  group('calendar page widget test', () {
    MockSecureStorage mockSecureStorage;
    MockFirebasePushService mockFirebasePushService;

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) => Future.value(Fakes.token));
      mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
    });

    testWidgets('Application starts', (WidgetTester tester) async {
      await tester.pumpWidget(App(
        httpClient: Fakes.client(),
        baseUrl: '',
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('Should show up empty', (WidgetTester tester) async {
      await tester.pumpWidget(App(
        httpClient: Fakes.client([]),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);
    });

    testWidgets('Should show one activity', (WidgetTester tester) async {
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.onTime()]),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });

    testWidgets('Empty agenda should not show Go to now-button',
        (WidgetTester tester) async {
      await tester.pumpWidget(App(
        httpClient: Fakes.client([]),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets('Agenda with one activity should not show Go to now-button',
        (WidgetTester tester) async {
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.onTime()]),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets('Agenda with one activity hidden by passed activities should show Go to now-button',
        (WidgetTester tester) async {
      await tester.pumpWidget(App(
        httpClient: Fakes.client(FakeActivities.allPast..add(FakeActivity.onTime())),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsOneWidget);
    });

  });
}
