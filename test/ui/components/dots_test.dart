import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);
  final day = startTime.onlyDays();
  final mockMemoplannerSettingsBloc = MockMemoplannerSettingsBloc();
  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ClockBloc>(
              create: (context) => ClockBloc(
                StreamController<DateTime>().stream,
                initialTime: startTime,
              ),
            ),
            BlocProvider<MemoplannerSettingBloc>(
              create: (context) => mockMemoplannerSettingsBloc,
            )
          ],
          child: widget,
        ),
      );

  setUp(() {
    // When settings are not loaded the default value will be used
    when(mockMemoplannerSettingsBloc.state)
        .thenReturn(MemoplannerSettingsNotLoaded());
    initializeDateFormatting();
  });

  group('ActivityInfoSideDots', () {
    testWidgets('Side dots shows for current activity',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        duration: 2.hours(),
        startTime: startTime,
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot), findsWidgets);
    });

    testWidgets('time remaning text shows for current activity',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        startTime: startTime.subtract(7.minutes()),
        duration: 2.hours(),
      );
      final expectedText = '''1 h
53 min
''';

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(expectedText), findsWidgets);
    });
    testWidgets('Side dots shows for future activity',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        duration: 2.hours(),
        startTime: startTime.add(30.minutes()),
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot), findsWidgets);
    });

    testWidgets('time remaning text shows for future activity',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        startTime: startTime.add(37.minutes()),
        duration: 2.hours(),
      );
      final expectedText = '''37 min
''';

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(expectedText), findsWidgets);
    });

    testWidgets('No side dots on past day', (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        duration: 2.hours(),
        startTime: startTime.previousDay(),
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day.previousDay(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot), findsNothing);
    });

    testWidgets('No side dots on past time', (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        duration: 2.hours(),
        startTime: startTime.subtract(3.hours()),
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot), findsNothing);
    });

    testWidgets('No side dots for current without end time',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        startTime: startTime,
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot), findsNothing);
    });

    testWidgets('Shows side dots for current without end time before start',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        startTime: startTime.add(1.minutes()),
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.byType(AnimatedDot), findsNWidgets(ActivityInfoSideDots.dots));
    });

    testWidgets('Correct amount of dots', (WidgetTester tester) async {
      // Arrange
      final minutes = 90;
      final activity = Activity.createNew(
        title: 'null',
        duration: minutes.minutes(),
        startTime: startTime,
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.byType(AnimatedDot), findsNWidgets(ActivityInfoSideDots.dots));
    });

    testWidgets('never more than max dots', (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        duration: 8.hours(),
        startTime: startTime,
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.byType(AnimatedDot), findsNWidgets(ActivityInfoSideDots.dots));
    });
    testWidgets('future activity shows dots', (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        duration: 1.hours(),
        startTime: startTime.add(1.hours()),
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.byType(AnimatedDot), findsNWidgets(ActivityInfoSideDots.dots));
    });

    testWidgets('Correct type of dots', (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        startTime: startTime.subtract(30.minutes()),
        duration: 88.minutes(),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();
      final dots = tester.widgetList<AnimatedDot>(find.byType(AnimatedDot));

      // Assert
      expect(dots, hasLength(ActivityInfoSideDots.dots));
      expect(dots.where((d) => d.decoration == currentDotShape), hasLength(0),
          reason: 'no current dots');
      expect(dots.where((d) => d.decoration == pastDotShape), hasLength(4),
          reason: 'four past dots');
      expect(dots.where((d) => d.decoration == futureDotShape), hasLength(4),
          reason: 'four future dots');
    });

    testWidgets('When 15 min left show one sub dot with 5 mini dots',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        startTime: startTime.subtract(15.minutes()),
        duration: 30.minutes(),
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SubQuarerDot), findsOneWidget);
      final dots = tester.widgetList<MiniDot>(find.byType(MiniDot)).toList();

      expect(dots, hasLength(5));
      expect(dots.where((d) => d.visible), hasLength(5), reason: '5 mini dots');
    });

    testWidgets('When 3 min left show one sub dot with 1 mini dot',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: 'null',
        startTime: startTime.subtract(15.minutes()),
        duration: 18.minutes(),
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoSideDots.from(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SubQuarerDot), findsOneWidget);
      final dots = tester.widgetList<MiniDot>(find.byType(MiniDot)).toList();
      expect(dots, hasLength(5));
      expect(dots.where((d) => d.visible), hasLength(1), reason: '1 mini dot');
    });
  });
}
