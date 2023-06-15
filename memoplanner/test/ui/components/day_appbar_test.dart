import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';

void main() {
  final now = DateTime(2023, 01, 02, 08, 00);
  final memoplannerSettingBloc = MockMemoplannerSettingBloc();
  final clockBloc = ClockBloc.fixed(now);
  final dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);

  setUpAll(() async {
    await Lokalise.initMock();
  });

  final providers = [
    BlocProvider<ClockBloc>(
      create: (context) => clockBloc,
    ),
    BlocProvider<MemoplannerSettingsBloc>(
      create: (context) => memoplannerSettingBloc,
    ),
    BlocProvider<TimepillarCubit>(
      create: (context) => FakeTimepillarCubit(),
    ),
    BlocProvider<DayPartCubit>(
      create: (context) => FakeDayPartCubit(),
    ),
    BlocProvider<SpeechSettingsCubit>(
      create: (context) => FakeSpeechSettingsCubit(),
    ),
    BlocProvider<DayPickerBloc>(
      create: (context) => dayPickerBloc,
    ),
    BlocProvider<NightMode>(
      create: (context) => FakeNightMode(),
    ),
    BlocProvider<ScrollPositionCubit>(
      create: (context) => FakeScrollPositionCubit(),
    ),
  ];

  Future<void> pumpDayCalendarAppBar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [Lt.delegate],
        home: MultiBlocProvider(
          providers: providers,
          child: const DayCalendarAppBar(),
        ),
      ),
    );
  }

  Future<void> pumpDayAppBar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [Lt.delegate],
        home: MultiBlocProvider(
          providers: providers,
          child: DayAppBar(
            day: now,
          ),
        ),
      ),
    );
  }

  group('DayCalendarAppBar', () {
    testWidgets('All settings on shows all components',
        (WidgetTester tester) async {
      when(() => memoplannerSettingBloc.state).thenAnswer(
        (_) => const MemoplannerSettings(
          dayAppBar: DayAppBarSettings(
            showBrowseButtons: true,
            showWeekday: true,
            showDayPeriod: true,
            showDate: true,
            showClock: true,
          ),
        ),
      );
      await pumpDayCalendarAppBar(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('2 January 2023'), findsOneWidget);
      expect(find.text('8:00 AM'), findsOneWidget);
      expect(find.byType(AbiliaClock), findsOneWidget);
      expect(find.text('mid-morning'), findsOneWidget);
      expect(find.byType(LeftNavButton), findsOneWidget);
      expect(find.byType(RightNavButton), findsOneWidget);
    });

    testWidgets('Some settings on shows AppBar with some components',
        (WidgetTester tester) async {
      when(() => memoplannerSettingBloc.state).thenAnswer(
        (_) => const MemoplannerSettings(
          dayAppBar: DayAppBarSettings(
            showBrowseButtons: false,
            showWeekday: true,
            showDayPeriod: true,
            showDate: true,
            showClock: false,
          ),
        ),
      );
      await pumpDayCalendarAppBar(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('2 January 2023'), findsOneWidget);
      expect(find.text('8:00 AM'), findsNothing);
      expect(find.text('mid-morning'), findsOneWidget);
      expect(find.byType(LeftNavButton), findsNothing);
      expect(find.byType(RightNavButton), findsNothing);
    });

    testWidgets('All settings off shows no AppBar',
        (WidgetTester tester) async {
      when(() => memoplannerSettingBloc.state).thenAnswer(
        (_) => const MemoplannerSettings(
          dayAppBar: DayAppBarSettings(
            showBrowseButtons: false,
            showWeekday: false,
            showDayPeriod: false,
            showDate: false,
            showClock: false,
          ),
        ),
      );
      await pumpDayCalendarAppBar(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('All settings off except showBrowseButtons shows AppBar',
        (WidgetTester tester) async {
      when(() => memoplannerSettingBloc.state).thenAnswer(
        (_) => const MemoplannerSettings(
          dayAppBar: DayAppBarSettings(
            showBrowseButtons: true,
            showWeekday: false,
            showDayPeriod: false,
            showDate: false,
            showClock: false,
          ),
        ),
      );
      await pumpDayCalendarAppBar(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Monday'), findsNothing);
      expect(find.text('2 January 2023'), findsNothing);
      expect(find.text('8:00 AM'), findsNothing);
      expect(find.text('mid-morning'), findsNothing);
      expect(find.byType(LeftNavButton), findsOneWidget);
      expect(find.byType(RightNavButton), findsOneWidget);
    });

    testWidgets('All settings off shows no AppBar',
        (WidgetTester tester) async {
      when(() => memoplannerSettingBloc.state).thenAnswer(
        (_) => const MemoplannerSettings(
          dayAppBar: DayAppBarSettings(
            showBrowseButtons: false,
            showWeekday: false,
            showDayPeriod: false,
            showDate: false,
            showClock: false,
          ),
        ),
      );
      await pumpDayCalendarAppBar(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('DayAppBar', () {
    testWidgets('All settings off except showBrowseButtons shows no AppBar',
        (WidgetTester tester) async {
      when(() => memoplannerSettingBloc.state).thenAnswer(
        (_) => const MemoplannerSettings(
          dayAppBar: DayAppBarSettings(
            showBrowseButtons: true,
            showWeekday: false,
            showDayPeriod: false,
            showDate: false,
            showClock: false,
          ),
        ),
      );
      await pumpDayAppBar(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsNothing);
    });
  });
}
