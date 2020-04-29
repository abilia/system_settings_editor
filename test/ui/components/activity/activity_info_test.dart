import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';

import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:uuid/uuid.dart';

import '../../../mocks.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);
  final day = startTime.onlyDays();
  final locale = Locale('en');
  final translator = Translated.dictionaries[locale];
  MockAuthenticationBloc mockedAuthenticationBloc;
  final String infoItemWithTestNote =
      'eyJpbmZvLWl0ZW0iOlt7InR5cGUiOiJub3RlIiwiZGF0YSI6eyJ0ZXh0IjoiVGVzdCJ9fV19';

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => mockedAuthenticationBloc),
          BlocProvider<ActivitiesBloc>(
            create: (context) => MockActivitiesBloc(),
          ),
          BlocProvider<UserFileBloc>(
            create: (context) => UserFileBloc(
              fileStorage: MockFileStorage(),
              pushBloc: MockPushBloc(),
              syncBloc: MockSyncBloc(),
              userFileRepository: MockUserFileRepository(),
            ),
          ),
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc(
              StreamController<DateTime>().stream,
              initialTime: startTime,
            ),
          )
        ], child: widget),
      );

  setUp(() {
    Locale.cachedLocale = locale;
    initializeDateFormatting();
    mockedAuthenticationBloc = MockAuthenticationBloc();
    GetItInitializer()
      ..fileStorage = MockFileStorage()
      ..init();
  });

  testWidgets('activity none checkable activity does not show check button ',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      reminderBefore: [],
    );

    // Act
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );

    // Assert
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.activityUncheckButton), findsNothing);
    expect(find.byKey(TestKey.activityCheckButton), findsNothing);
  });

  testWidgets('activity checkable activity show check button ',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      checkable: true,
      reminderBefore: [],
    );

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
    expect(find.byKey(TestKey.activityUncheckButton), findsNothing);
  });

  testWidgets('signed off shows signed off button',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      checkable: true,
      reminderBefore: [],
      signedOffDates: [day],
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(TestKey.activityCheckButton), findsNothing);
    expect(find.byKey(TestKey.activityUncheckButton), findsOneWidget);
  });

  testWidgets('pressing signed off ', (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      category: 0,
      checkable: true,
      reminderBefore: [],
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.activityCheckButton));
  });

  testWidgets('shows attatchment', (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      category: 0,
      reminderBefore: [],
      infoItem: infoItemWithTestNote,
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(TestKey.attachment), findsOneWidget);
  });

  testWidgets('full day', (WidgetTester tester) async {
    // Arrange
    final title = 'thefirsttitls';
    final activity = Activity.createNew(
      title: title,
      startTime: startTime,
      category: 0,
      reminderBefore: [],
      fullDay: true,
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(translator.fullDay), findsOneWidget);
  });

  testWidgets('image and no attatchment', (WidgetTester tester) async {
    // Arrange
    final title = 'thefirsttitls';
    final activity = Activity.createNew(
      title: title,
      startTime: startTime,
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Hero), findsOneWidget);
  });

  testWidgets('image to the left -> (hasImage && hasAttachment && hasTitle)',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: infoItemWithTestNote,
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Hero), findsOneWidget);
  });

  testWidgets('image below -> (hasImage && hasAttachment && !hasTitle)',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: null,
      startTime: startTime,
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: infoItemWithTestNote,
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Hero), findsOneWidget);
  });

  testWidgets('Note attachment is present', (WidgetTester tester) async {
    final activity = Activity.createNew(
      title: null,
      startTime: startTime,
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: infoItemWithTestNote,
    );

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NoteBlock), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });
  group('ActivityInfoWithDots', () {
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
          ActivityInfoWithDots(
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
          ActivityInfoWithDots(
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
          ActivityInfoWithDots(
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
          ActivityInfoWithDots(
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
          ActivityInfoWithDots(
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
          ActivityInfoWithDots(
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
          ActivityInfoWithDots(
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
          ActivityInfoWithDots(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot),
          findsNWidgets(ActivityInfoSideDots.maxDots));
    });

    testWidgets('Correct amount of dots', (WidgetTester tester) async {
      // Arrange
      final minutes = 90;
      final exptectedDots = minutes ~/ minutesPerDot;
      final activity = Activity.createNew(
        title: 'null',
        duration: minutes.minutes(),
        startTime: startTime,
      );

      // Act
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoWithDots(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot), findsNWidgets(exptectedDots));
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
          ActivityInfoWithDots(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot),
          findsNWidgets(ActivityInfoSideDots.maxDots));
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
          ActivityInfoWithDots(
            activity: activity,
            day: day,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AnimatedDot),
          findsNWidgets(ActivityInfoSideDots.maxDots));
    });

    testWidgets('Correct type of dots', (WidgetTester tester) async {
      final activity = Activity.createNew(
        title: 'null',
        startTime: startTime.subtract(30.minutes()),
        duration: 88.minutes(),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(
          ActivityInfoWithDots(
            activity: activity,
            day: day,
          ),
        ),
      );

      await tester.pumpAndSettle();
      final dots = tester.widgetList<AnimatedDot>(find.byType(AnimatedDot));

      expect(dots, hasLength(6));
      expect(dots.where((d) => d.decoration == currentDotShape), hasLength(0),
          reason: 'no current dots');
      expect(dots.where((d) => d.decoration == pastDotShape), hasLength(2),
          reason: 'two past dots');
      expect(dots.where((d) => d.decoration == futureDotShape), hasLength(4),
          reason: 'four future dots');
    });
  });
}
