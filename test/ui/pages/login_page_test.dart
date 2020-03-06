import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/ui/pages/login_page.dart';

import '../../mocks.dart';

void main() {
  group('login page widget test', () {
    final secretPassword = 'pwfafawfa';

    setUp(() {
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(null));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      MockActivityDb mockActivityDb = MockActivityDb();
      when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(0));
      when(mockActivityDb.getActivities())
          .thenAnswer((_) => Future.value([]));
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..fireBasePushService = mockFirebasePushService
        ..userDb = MockUserDb()
        ..baseUrlDb = MockBaseUrlDb()
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(() => [])
        ..init();
    });

    testWidgets('Application starts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Hide password button', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byKey(TestKey.hidePasswordToggle), findsNothing);
      expect(find.byKey(TestKey.passwordInput), findsOneWidget);

      await tester.enterText(find.byKey(TestKey.passwordInput), secretPassword);
      await tester.pump();

      expect(find.byKey(TestKey.hidePasswordToggle), findsOneWidget);
      await tester.tap(find.byKey(TestKey.hidePasswordToggle));
      expect(find.text(secretPassword), findsOneWidget);

      await tester.enterText(find.byKey(TestKey.passwordInput), '');
      await tester.pump();
      expect(find.byKey(TestKey.hidePasswordToggle), findsNothing);
    });

    testWidgets('Cant login when no password or username',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(TestKey.passwordInput), secretPassword);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsNothing);

      await tester.enterText(find.byKey(TestKey.passwordInput), '');
      await tester.enterText(find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsNothing);
    });

    testWidgets('Error message when incorrect username or password',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.enterText(
          find.byKey(TestKey.passwordInput), Fakes.incorrectPassword);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsNothing);
      expect(find.byKey(TestKey.loginError), findsOneWidget);
    });

    testWidgets('Can login', (WidgetTester tester) async {
      await tester.pumpWidget(App());

      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(TestKey.passwordInput), secretPassword);
      await tester.enterText(find.byKey(TestKey.userNameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byKey(TestKey.loggInButton));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });
  });
}
