import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';

import '../../test_helpers/register_fallback_values.dart';
import '../../test_helpers/tts.dart';

void main() {
  final day = DateTime(2111, 11, 11);
  late MockDayEventsCubit dayEventsCubitMock;
  late FakeTimepillarCubit timepillarCubit;

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => FakeAuthenticationBloc()),
          BlocProvider<DayEventsCubit>(
            create: (context) => dayEventsCubitMock,
          ),
          BlocProvider<ActivitiesBloc>(
            create: (context) => FakeActivitiesBloc(),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.fixed(day),
          ),
          BlocProvider<MemoplannerSettingBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<TimepillarCubit>(
            create: (context) => timepillarCubit,
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(
              settingsDb: FakeSettingsDb(),
            ),
          ),
        ], child: widget),
      );

  const title0 = 'allDay0',
      title1 = 'allDay1',
      title2 = 'allDay2',
      title3 = 'allDay3';

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    await initializeDateFormatting();
    setupFakeTts();
    dayEventsCubitMock = MockDayEventsCubit();
    timepillarCubit = FakeTimepillarCubit();
    final allDayActivities = [
      title0,
      title1,
      title2,
      title3,
    ]
        .map(
          (t) => ActivityOccasion(
            Activity.createNew(
              title: t,
              startTime: day,
              fullDay: true,
            ),
            day,
            Occasion.future,
          ),
        )
        .toList();

    final expected = EventsState(
      activities: const [],
      timers: const [],
      fullDayActivities: allDayActivities,
      day: day,
      occasion: Occasion.current,
    );

    when(() => dayEventsCubitMock.state).thenReturn(expected);
    when(() => dayEventsCubitMock.stream)
        .thenAnswer((_) => Stream.fromIterable([expected]));
    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('All DayList shows', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const AllDayList()));
    await tester.pumpAndSettle();
    expect(find.text(title0), findsOneWidget);
    expect(find.text(title1), findsOneWidget);
    expect(find.text(title2), findsOneWidget);
    expect(find.text(title3), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const AllDayList()));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.text(title0), contains: title0);
  });
}
