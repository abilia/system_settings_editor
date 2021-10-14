import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../fakes/all.dart';
import '../../mocks/shared.mocks.dart';

import '../../test_helpers/tts.dart';

void main() {
  final day = DateTime(2111, 11, 11);
  final activitiesOccasionBlocMock = MockActivitiesOccasionBloc();
  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => FakeAuthenticationBloc()),
          BlocProvider<ActivitiesOccasionBloc>(
            create: (context) => activitiesOccasionBlocMock,
          ),
          BlocProvider<ActivitiesBloc>(
            create: (context) => FakeActivitiesBloc(),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc(StreamController<DateTime>().stream,
                initialTime: day),
          ),
          BlocProvider<MemoplannerSettingBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: FakeSettingsDb(),
            ),
          ),
        ], child: widget),
      );

  const title0 = 'allDay0',
      title1 = 'allDay1',
      title2 = 'allDay2',
      title3 = 'allDay3';
  setUp(() async {
    await initializeDateFormatting();
    setupFakeTts();
    final allDayActivities = [
      Activity.createNew(
        title: title0,
        startTime: day,
      ),
      Activity.createNew(
        title: title1,
        startTime: day,
      ),
      Activity.createNew(
        title: title2,
        startTime: day,
      ),
      Activity.createNew(
        title: title3,
        startTime: day,
      ),
    ].map((a) => ActivityDay(a, day).toOccasion(day)).toList();

    final expected = ActivitiesOccasionLoaded(
      activities: const [],
      fullDayActivities: allDayActivities,
      day: day,
      occasion: Occasion.current,
    );

    when(activitiesOccasionBlocMock.state).thenReturn(expected);
    when(activitiesOccasionBlocMock.stream)
        .thenAnswer((_) => Stream.fromIterable([expected]));
    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('All DayList shows', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(AllDayList()));
    await tester.pumpAndSettle();
    expect(find.text(title0), findsOneWidget);
    expect(find.text(title1), findsOneWidget);
    expect(find.text(title2), findsOneWidget);
    expect(find.text(title3), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(AllDayList()));
    await tester.pumpAndSettle();
    await tester.verifyTts(find.text(title0), contains: title0);
  });
}
