import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uuid/uuid.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);
  final day = startTime.onlyDays();
  MockAuthenticationBloc mockedAuthenticationBloc;
  final infoItemWithTestNote = InfoItem.fromBase64(
          'eyJpbmZvLWl0ZW0iOlt7InR5cGUiOiJub3RlIiwiZGF0YSI6eyJ0ZXh0IjoiVGVzdCJ9fV19')
      as NoteInfoItem;
  final translate = Locales.language.values.first;

  Widget wrapWithMaterialApp(Widget widget) => MockAuthenticatedBlocsProvider(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
                create: (context) => mockedAuthenticationBloc),
            BlocProvider<UserFileBloc>(
              create: (context) => UserFileBloc(
                fileStorage: MockFileStorage(),
                pushBloc: MockPushBloc(),
                syncBloc: MockSyncBloc(),
                userFileRepository: MockUserFileRepository(),
              ),
            ),
            BlocProvider<ClockBloc>(
              create: (context) =>
                  ClockBloc(StreamController<DateTime>().stream),
            ),
            BlocProvider<SettingsBloc>(
              create: (context) => SettingsBloc(
                settingsDb: MockSettingsDb(),
              ),
            ),
          ],
          child: MaterialApp(
            supportedLocales: Translator.supportedLocals,
            localizationsDelegates: [Translator.delegate],
            localeResolutionCallback: (locale, supportedLocales) =>
                supportedLocales.firstWhere(
                    (l) => l.languageCode == locale?.languageCode,
                    orElse: () => supportedLocales.first),
            home: Material(child: widget),
          ),
        ),
      );

  setUp(() {
    initializeDateFormatting();
    mockedAuthenticationBloc = MockAuthenticationBloc();
    GetItInitializer()
      ..fileStorage = MockFileStorage()
      ..alarmScheduler = noAlarmScheduler
      ..database = MockDatabase()
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  tearDown(GetIt.I.reset);

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
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );

    // Assert
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.uncheckButton), findsNothing);
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
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
    expect(find.byKey(TestKey.uncheckButton), findsNothing);

    await tester.verifyTts(find.byKey(TestKey.activityCheckButton));
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
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(TestKey.activityCheckButton), findsNothing);
    expect(find.byKey(TestKey.uncheckButton),
        findsNothing); // uncheck only in bottom bar
  });

  testWidgets('activity with null title', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo.from(
          activity: Activity.createNew(
            title: null,
            fileId: Uuid().v4(),
            startTime: startTime,
          ),
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CheckedImageWithImagePopup), findsOneWidget);
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
        ActivityInfo.from(
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
        ActivityInfo.from(
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
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(Locales.language.values.first.fullDay), findsOneWidget);
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
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ActivityImage), findsOneWidget);
    expect(find.text(activity.title), findsOneWidget);
    expect(find.byType(Attachment), findsNothing);
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
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ActivityImage), findsOneWidget);
    expect(find.text(activity.title), findsOneWidget);
    expect(find.byType(Attachment), findsOneWidget);
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
        ActivityInfo.from(
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
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NoteBlock), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('Checklist from base64 attachment is present',
      (WidgetTester tester) async {
    final activity = Activity.createNew(
      title: null,
      startTime: startTime,
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: InfoItem.fromBase64(
          'eyJpbmZvLWl0ZW0iOlt7InR5cGUiOiJjaGVja2xpc3QiLCJkYXRhIjp7ImNoZWNrZWQiOnsiMjAyMDA1MDYiOlsxLDRdfSwicXVlc3Rpb25zIjpbeyJpZCI6MCwibmFtZSI6InNob3J0cyIsImltYWdlIjoiL0hhbmRpL1VzZXIvUGljdHVyZS9zaG9ydHMuanBnIiwiZmlsZUlkIjoiOGM1ZDE0YTItYzIzZi00YTI0LTg0ZGItYmE5NjBhMGVjYjM4IiwiY2hlY2tlZCI6ZmFsc2V9LHsiaWQiOjEsIm5hbWUiOiJ0LXRyw7ZqYSIsImltYWdlIjoiL0hhbmRpL1VzZXIvUGljdHVyZS90LXRyw7ZqYS5qcGciLCJmaWxlSWQiOiIxOGNlODhlOS04Zjc4LTRiZjQtYWM0Yy0wY2JhYmZlMmI3NzQiLCJjaGVja2VkIjp0cnVlfSx7ImlkIjoyLCJuYW1lIjoic3RydW1wb3IiLCJpbWFnZSI6Ii9IYW5kaS9Vc2VyL1BpY3R1cmUvc3RydW1wb3IuanBnIiwiZmlsZUlkIjoiYjdmY2YwYWMtNmQwYS00MzVlLWFlNTYtMzNlYzE0NDVmOTc5IiwiY2hlY2tlZCI6ZmFsc2V9LHsiaWQiOjMsIm5hbWUiOiJneW1uYXN0aWtza29yIiwiaW1hZ2UiOiIvSGFuZGkvVXNlci9QaWN0dXJlL2d5bW5hc3Rpa3Nrb3IuanBnIiwiZmlsZUlkIjoiZjIyYWMxZDgtYmNjNi00YTQ2LWE4ZWQtOGQ4OGExNjU1MjlkIiwiY2hlY2tlZCI6ZmFsc2V9LHsiaWQiOjQsIm5hbWUiOiJ2YXR0ZW5mbGFza2EiLCJpbWFnZSI6Ii9IYW5kaS9Vc2VyL1BpY3R1cmUvdmF0dGVuZmxhc2thLmpwZyIsImZpbGVJZCI6IjMzYTBmMmE0LTRlYzktNDFmOC05MGU0LWU2YmU4OTdlNjcxZCIsImNoZWNrZWQiOnRydWV9LHsiaWQiOjUsIm5hbWUiOiJoYW5kZHVrIiwiaW1hZ2UiOiIvSGFuZGkvVXNlci9QaWN0dXJlL2hhbmRkdWsuanBnIiwiZmlsZUlkIjoiNjgwZGQxOTEtMzBiMS00NDU0LTk5Y2YtMzNiN2I5OTVmYTMwIiwiY2hlY2tlZCI6ZmFsc2V9LHsiaWQiOjYsIm5hbWUiOiJ0dsOlbCIsImltYWdlIjoiL0hhbmRpL1VzZXIvUGljdHVyZS9mbHl0YW5kZSB0dsOlbC5qcGciLCJmaWxlSWQiOiJmODI0OTQ3Ny0zYWRmLTRkODgtOWIxZS1lZWY4M2I0NzY0ZTEiLCJjaGVja2VkIjpmYWxzZX0seyJuYW1lIjoia2Fsc29uZ2VyXG5rYWxzb25nZXJcbmthbHNvbmdlclxua2Fsc29uZ2VyIiwiaW1hZ2UiOiIvSGFuZGkvVXNlci9QaWN0dXJlL2thbHNvbmdlci5qcGciLCJmaWxlSWQiOiIwMDA1NmYxNi02OWJmLTRlZjEtOTBjNi1lOTFiNjY5MjliYWYiLCJpZCI6NywiY2hlY2tlZCI6ZmFsc2V9XX19XX0='),
    );

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CheckListView), findsOneWidget);
    expect(find.text('shorts'), findsOneWidget);
  });

  testWidgets('Checklist with long item still shows checkbox (bug SGC-387)',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(ActivityInfo.from(
        activity: Activity.createNew(
            title: 'title',
            startTime: startTime,
            infoItem: Checklist(questions: [
              Question(
                id: 1,
                name:
                    'Long long long long long long long long long long long long long long long long',
              ),
            ])),
        day: day)));
    await tester.pumpAndSettle();

    expect(find.byIcon(AbiliaIcons.checkbox_unselected), findsOneWidget);
  });

  testWidgets('Test open checklist image in fullscreen',
      (WidgetTester tester) async {
    final infoItem = Checklist(questions: [
      Question(
        id: 1,
        fileId: Uuid().v4(),
      )
    ]);

    final activity = Activity.createNew(
      title: null,
      startTime: startTime,
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: infoItem,
    );

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CheckListView), findsOneWidget);
    expect(find.byType(QuestionView), findsOneWidget);
    expect(find.byKey(TestKey.checklistQuestionImageKey), findsOneWidget);
    await tester.tap(find.byKey(TestKey.checklistQuestionImageKey));
    await tester.pumpAndSettle();
    expect(find.byType(FullScreenImage), findsOneWidget);
  });

  testWidgets('Checklist attachment is present and not signed off',
      (WidgetTester tester) async {
    final checklist = Checklist(questions: [
      Question(id: 0, name: 'tag'),
      Question(id: 1, fileId: 'fileid'),
    ]);
    final activity = Activity.createNew(
      title: null,
      startTime: startTime,
      category: 0,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: checklist,
    );

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CheckListView), findsOneWidget);
    expect(find.byType(QuestionView), findsNWidgets(2));
    expect(find.text('tag'), findsOneWidget);
    tester.widgetList(find.byType(QuestionView)).forEach((element) {
      if (element is QuestionView) {
        expect(element.signedOff, isFalse);
      }
    });

    await tester.verifyTts(find.text(checklist.questions.first.name),
        exact: checklist.questions.first.name);
  });

  testWidgets('Checklist attachment is present and signed off',
      (WidgetTester tester) async {
    final activity = Activity.createNew(
        title: null,
        startTime: startTime,
        category: 0,
        checkable: true,
        reminderBefore: [],
        fileId: Uuid().v4(),
        infoItem: Checklist(questions: [
          Question(id: 0, name: 'tag'),
          Question(id: 1, fileId: 'fileid'),
        ], checked: {
          Checklist.dayKey(day): {0, 1}
        }));

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CheckListView), findsOneWidget);
    expect(find.byType(QuestionView), findsNWidgets(2));
    expect(find.text('tag'), findsOneWidget);
    tester.widgetList(find.byType(QuestionView)).forEach((element) {
      if (element is QuestionView) {
        expect(element.signedOff, isTrue);
      }
    });
  });

  testWidgets('Show image in fullscreen', (WidgetTester tester) async {
    // Arrange
    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      category: 0,
      reminderBefore: [],
      infoItem: infoItemWithTestNote,
      fileId: Uuid().v4(),
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(TestKey.viewImage), findsOneWidget);
    await tester.tap(find.byKey(TestKey.viewImage));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoView), findsOneWidget);
  });

  testWidgets(
      'ConfirmActivityActionDialog is shown when last question in checked',
      (WidgetTester tester) async {
    final activity = Activity.createNew(
        title: null,
        startTime: startTime,
        category: 0,
        checkable: true,
        reminderBefore: [],
        fileId: Uuid().v4(),
        infoItem: Checklist(questions: [
          Question(id: 0, name: 'checked'),
          Question(id: 1, name: 'unchecked'),
        ], checked: {
          Checklist.dayKey(day): {0}
        }));

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CheckListView), findsOneWidget);
    expect(find.byType(QuestionView), findsNWidgets(2));
    await tester.tap(find.text('unchecked'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckActivityConfirmDialog), findsOneWidget);
  });

  testWidgets('Tts with note', (WidgetTester tester) async {
    final activity = Activity.createNew(
      title: 'a title',
      startTime: startTime,
      duration: 1.hours(),
      category: 0,
      checkable: true,
      reminderBefore: [],
      fileId: Uuid().v4(),
      infoItem: infoItemWithTestNote,
    );

    await tester.pumpWidget(
      wrapWithMaterialApp(
        ActivityInfo.from(
          activity: activity,
          day: day,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.verifyTts(find.byType(NoteBlock),
        exact: infoItemWithTestNote.text);

    await tester.verifyTts(find.text(activity.title), exact: activity.title);

    await tester.verifyTts(find.byKey(TestKey.activityCheckButton),
        exact: translate.check);

    await tester.verifyTts(find.byKey(TestKey.startTime));

    await tester.verifyTts(find.byKey(TestKey.endTime));
  });
}
