import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/listener/inactivity_listener.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../fakes/all.dart';
import '../mocks/mocks.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  final DateTime initialTime = DateTime(2122, 06, 06, 06, 00);
  final Ticker fakeTicker = Ticker.fake(initialTime: initialTime);
  final MemoplannerSettingBloc settingBloc = FakeMemoplannerSettingsBloc();
  final ClockBloc clockBloc =
      ClockBloc(fakeTicker.minutes, initialTime: initialTime);
  late InactivityCubit inactivityCubit;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    setupPermissions();
    inactivityCubit =
        InactivityCubit(const Duration(minutes: 1), clockBloc, settingBloc);
    final mockFirebasePushService = MockFirebasePushService();
    when(() => mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = fakeTicker
      ..client = Fakes.client(
        activityResponse: () => [],
      )
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(() {
    inactivityCubit.close();
    GetIt.I.reset();
  });

  Widget _wrapWithMaterialApp({Widget? child}) => TopLevelBlocsProvider(
        runStartGuide: false,
        child: AuthenticatedBlocsProvider(
          memoplannerSettingBloc: settingBloc,
          authenticatedState: const Authenticated(token: '', userId: 1),
          child: BlocProvider<InactivityCubit>(
            create: (context) => inactivityCubit,
            child: MaterialApp(
              theme: abiliaTheme,
              home: MultiBlocListener(listeners: [
                CalendarInactivityListener(),
                HomeScreenInactivityListener(),
              ], child: child ?? Container()),
            ),
          ),
        ),
      );

  group('Home screen inactivity', () {
    testWidgets(
        'When timeout is reached, screen saver is false, app switches to WeekCalendar',
        (tester) async {
      await tester
          .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
      inactivityCubit.emit(
        const HomeScreenInactivityThresholdReached(
            StartView.weekCalendar, false),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets(
        'When timeout is reached, screen saver is false, app switches to MonthCalendar',
        (tester) async {
      await tester
          .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
      inactivityCubit.emit(
        const HomeScreenInactivityThresholdReached(
            StartView.monthCalendar, false),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MonthCalendar), findsOneWidget);
    });

    testWidgets(
        'When timeout is reached, screen saver is false, app switches to Menu',
        (tester) async {
      await tester
          .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
      inactivityCubit.emit(
        const HomeScreenInactivityThresholdReached(StartView.menu, false),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
    });

    testWidgets(
        'When timeout is reached, screen saver is false, app switches to PhotoCalendar',
        (tester) async {
      await tester
          .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
      inactivityCubit.emit(
        const HomeScreenInactivityThresholdReached(StartView.photoAlbum, false),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PhotoCalendarPage), findsOneWidget);
    });

    testWidgets(
        'When timeout is reached, screen saver is true, app switches to ScreenSaver',
        (tester) async {
      await tester
          .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
      inactivityCubit.emit(
        const HomeScreenInactivityThresholdReached(StartView.menu, true),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ScreenSaverPage), findsOneWidget);
    });
  }, skip: Config.isMPGO);

  group('Calendar inactivity', () {
    final local = Intl.getCurrentLocale();
    testWidgets('When timeout is reached, day calendar switches to current day',
        (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(child: const DayCalendar()));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      expect(
          find.text(DateFormat.EEEE(local).format(initialTime)), findsNothing);
      inactivityCubit.emit(
        const CalendarInactivityThresholdReached(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DayCalendar), findsOneWidget);
      expect(find.text(DateFormat.EEEE(local).format(initialTime)),
          findsOneWidget);
    });

    testWidgets('When timeout is reached, if not in calendar, do nothing',
        (tester) async {
      await tester
          .pumpWidget(_wrapWithMaterialApp(child: const SettingsPage()));
      await tester.pumpAndSettle();
      inactivityCubit.emit(
        const CalendarInactivityThresholdReached(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DayCalendar), findsNothing);
    });
  });
}
