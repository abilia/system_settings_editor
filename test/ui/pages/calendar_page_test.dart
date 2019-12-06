import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/bloc/bloc_delegate.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';

import '../../mocks.dart';

void main() {
  group('calendar page widget test', () {
    MockSecureStorage mockSecureStorage;
    MockFirebasePushService mockFirebasePushService;
    MockActivityDb mockActivityDb;
    MockPushBloc mockPushBloc;

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) => Future.value(Fakes.token));
      mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      mockActivityDb = MockActivityDb();
      mockPushBloc = MockPushBloc();
      GetItInitializer()
          .withPushBloc(mockPushBloc)
          .withActivityDb(mockActivityDb)
          .withUserDb(MockUserDb())
          .init();
    });

    testWidgets('Application starts', (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([]),
        baseUrl: '',
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('Should show up empty', (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([]),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);
    });

    testWidgets('Should show one activity', (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[FakeActivity.onTime()]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.future()]),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });

    testWidgets('Empty agenda should not show Go to now-button',
        (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[]));
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
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[FakeActivity.onTime()]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.onTime()]),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets(
        'Agenda with one activity hidden by passed activities should show Go to now-button',
        (WidgetTester tester) async {
      BlocSupervisor.delegate = SimpleBlocDelegate();
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(FakeActivities.allPast..add(FakeActivity.onTime())));
      await tester.pumpWidget(App(
        httpClient:
            Fakes.client(FakeActivities.allPast..add(FakeActivity.onTime())),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle(Duration(seconds: 10));
      expect(find.byKey(TestKey.goToNowButton), findsOneWidget);
    });

    testWidgets('Alarms shows', (WidgetTester tester) async {
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.onTime()]),
        firebasePushService: mockFirebasePushService,
        secureStorage: mockSecureStorage,
      ));
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    }, skip: true); // Unskip when we can Inject our own ticker
  });
}
