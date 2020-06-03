import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../mocks.dart';

void main() {
  AuthenticationBloc mockAuthenticationBloc = MockAuthenticationBloc();
  final day = DateTime(2111, 11, 11);
  final clocBloc =
      ClockBloc(StreamController<DateTime>().stream, initialTime: day);
  final activitiesOccasionBloc = ActivitiesOccasionBloc(
    clockBloc: clocBloc,
    dayActivitiesBloc: MockDayActivitiesBloc(),
    dayPickerBloc: MockDayPickerBloc(),
  );

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => mockAuthenticationBloc),
          BlocProvider<ActivitiesOccasionBloc>(
            create: (context) => activitiesOccasionBloc,
          ),
          BlocProvider<ActivitiesBloc>(
            create: (context) => MockActivitiesBloc(),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => clocBloc,
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
    ];

    activitiesOccasionBloc.add(ActivitiesChanged(allDayActivities, day));
    activitiesOccasionBloc.listen((state) {
      print(state);
      print('Got ya');
    });
    await Future.delayed(Duration(seconds: 2));

    await tester.pumpWidget(wrapWithMaterialApp(AllDayList()));
    await tester.pumpAndSettle();
    print('Starting to expect');
    expect(find.text(title0), findsOneWidget);
    expect(find.text(title1), findsOneWidget);
    expect(find.text(title2), findsOneWidget);
    expect(find.text(title3), findsOneWidget);
  });
}
