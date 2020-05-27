import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../mocks.dart';

void main() {
  AuthenticationBloc mockedActivitiesBloc = MockAuthenticationBloc();
  final day = DateTime(2111, 11, 11);

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => mockedActivitiesBloc),
          BlocProvider<ActivitiesBloc>(
              create: (context) => MockActivitiesBloc()),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc(StreamController<DateTime>().stream,
                initialTime: day),
          )
        ], child: widget),
      );

  setUp(() {
    initializeDateFormatting();
  });
  testWidgets('All DayList shows', (WidgetTester tester) async {
    final title0 = 'allDay0',
        title1 = 'allDay1',
        title2 = 'allDay2',
        title3 = 'allDay3';
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
    ].map((a) => ActivityOccasion(a, now: day, day: day)).toList();

    await tester.pumpWidget(wrapWithMaterialApp(AllDayList(
      allDayActivities: allDayActivities,
      pickedDay: day,
    )));
    await tester.pumpAndSettle();
    expect(find.text(title0), findsOneWidget);
    expect(find.text(title1), findsOneWidget);
    expect(find.text(title2), findsOneWidget);
    expect(find.text(title3), findsOneWidget);
  });
}
