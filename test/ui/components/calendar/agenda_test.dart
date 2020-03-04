import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';

import '../../../mocks.dart';

void main() {
  MockActivityDb mockActivityDb;
  DateTime now = DateTime.now();

  final firstFullDayTitle = 'first full day',
      secondFullDayTitle = 'second full day',
      thirdFullDayTitle = 'third full day',
      forthFullDayTitle = 'forth full day';
  final firstFullDay =
          FakeActivity.fullday(now).copyWith(title: firstFullDayTitle),
      secondFullDay =
          FakeActivity.fullday(now).copyWith(title: secondFullDayTitle),
      thirdFullDay =
          FakeActivity.fullday(now).copyWith(title: thirdFullDayTitle),
      forthFullDay =
          FakeActivity.fullday(now).copyWith(title: forthFullDayTitle);

  setUp(() {
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockTokenDb = MockTokenDb();
    when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    mockActivityDb = MockActivityDb();
    GetItInitializer()
      ..activityDb = mockActivityDb
      ..userDb = MockUserDb()
      ..ticker = (() => StreamController<DateTime>().stream)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..tokenDb = mockTokenDb
      ..httpClient = Fakes.client(() => [])
      ..init();
  });

  testWidgets('full day shows', (WidgetTester tester) async {
    when(mockActivityDb.getActivities())
        .thenAnswer((_) => Future.value([firstFullDay]));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
  });

  testWidgets('two full day shows, but no show all full days button',
      (WidgetTester tester) async {
    when(mockActivityDb.getActivities())
        .thenAnswer((_) => Future.value([firstFullDay, secondFullDay]));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.byKey(TestKey.showAllFullDays), findsNothing);
  });

  testWidgets(
      'two full day and show-all-full-day-button shows, but not third full day',
      (WidgetTester tester) async {
    when(mockActivityDb.getActivities()).thenAnswer(
        (_) => Future.value([firstFullDay, secondFullDay, thirdFullDay]));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsNothing);
    expect(find.byKey(TestKey.showAllFullDays), findsOneWidget);
  });

  testWidgets('tapping show-all-full-day-button shows all full days',
      (WidgetTester tester) async {
    when(mockActivityDb.getActivities()).thenAnswer((_) => Future.value([
          firstFullDay,
          secondFullDay,
          thirdFullDay,
          forthFullDay,
        ]));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsNothing);
    expect(find.text(forthFullDayTitle), findsNothing);
    expect(find.byKey(TestKey.showAllFullDays), findsOneWidget);

    await tester.tap(find.byKey(TestKey.showAllFullDays));
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsOneWidget);
    expect(find.text(forthFullDayTitle), findsOneWidget);
  });

  testWidgets('tapping on a full day shows the full day',
      (WidgetTester tester) async {
    when(mockActivityDb.getActivities())
        .thenAnswer((_) => Future.value([firstFullDay]));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.text(firstFullDayTitle));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPage), findsOneWidget);
  });

  testWidgets(
      'tapping show-all-full-day-button then on a full day shows all the tapped full day',
      (WidgetTester tester) async {
    when(mockActivityDb.getActivities()).thenAnswer((_) => Future.value([
          firstFullDay,
          secondFullDay,
          thirdFullDay,
          forthFullDay,
        ]));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.showAllFullDays));
    await tester.pumpAndSettle();
    await tester.tap(find.text(forthFullDayTitle));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPage), findsOneWidget);
    expect(find.text(forthFullDayTitle), findsOneWidget);
  });
}
