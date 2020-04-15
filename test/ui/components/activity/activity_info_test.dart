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
            create: (context) => ClockBloc(StreamController<DateTime>().stream),
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
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
      category: 0,
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
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
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

    // Assert
    expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
    expect(find.byKey(TestKey.activityUncheckButton), findsNothing);
  });

  testWidgets('signed off shows signed off button',
      (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
      category: 0,
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
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
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
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
      category: 0,
      reminderBefore: [],
      infoItem: 'some info item',
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
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
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
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
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
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: 'infoitem',
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
      startTime: startTime.millisecondsSinceEpoch,
      duration: 0,
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: 'infoitem',
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
}
