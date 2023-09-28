import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:webview_flutter/webview_flutter.dart';

import '../../fakes/all.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/enter_text.dart';
import '../../test_helpers/tts.dart';

void main() {
  late ActivityDbInMemory mockActivityDb;
  late MockGenericDb mockGenericDb;

  late final Lt translate;
  final startTime = DateTime(2111, 11, 11, 11, 11);
  final tenDaysAgo = DateTime(2111, 11, 01, 11, 11);

  final activityBackButtonFinder = find.byKey(TestKey.activityBackButton);
  final activityTimepillarCardFinder = find.byType(ActivityTimepillarCard);
  final activityCardFinder = find.byType(ActivityCard);
  final activityPageFinder = find.byType(ActivityPage);
  final timepillarFinder = find.byType(OneTimepillarCalendar);

  final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
  final finishActivityFinder = find.byType(NextWizardStepButton);

  final alarmButtonFinder = find.byKey(TestKey.editAlarm);
  final alarmAtStartSwitchFinder = find.byKey(TestKey.alarmAtStartSwitch);

  final okInkWellFinder = find.byKey(const ObjectKey(TestKey.okDialog));
  final okButtonFinder = find.byType(OkButton);
  final cancelButtonFinder = find.byType(CancelButton);

  final deleteButtonFinder = find.byIcon(AbiliaIcons.deleteAllClear);
  final yesNoDialogFinder = find.byType(YesNoDialog);

  final checkButtonFinder = find.byKey(TestKey.activityCheckButton);
  final uncheckButtonFinder = find.byKey(TestKey.uncheckButton);
  final yesButtonFinder = find.byType(YesButton);
  final noButtonFinder = find.byType(NoButton);

  ActivityResponse activityResponse = () => [];

  final activityInfoSideDotsFinder = find.byType(ActivityInfoSideDots);
  setUpAll(() async {
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  setUp(() async {
    setupPermissions();
    setupFakeTts();
    tz.initializeTimeZones();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;

    mockActivityDb = ActivityDbInMemory();
    mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker.fake(initialTime: startTime)
      ..fireBasePushService = FakeFirebasePushService()
      ..client = fakeClient(
        activityResponse: () => activityResponse(),
        licenseResponse: () => licenseResponseExpires(startTime.add(5.days())),
      )
      ..fileStorage = FakeFileStorage()
      ..genericDb = mockGenericDb
      ..userFileDb = FakeUserFileDb()
      ..sortableDb = FakeSortableDb()
      ..database = FakeDatabase()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
    activityResponse = () => [];
  });

  Future<void> navigateToActivityPage(WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(activityTimepillarCardFinder);
    await tester.pumpAndSettle();
  }

  Future<void> navigateToFullDayActivityPage(WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    await tester.tap(activityCardFinder);
    await tester.pumpAndSettle();
  }

  group('Activity page', () {
    testWidgets('Navigate to activity page and back',
        (WidgetTester tester) async {
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      await navigateToActivityPage(tester);
      expect(activityBackButtonFinder, findsOneWidget);
      await tester.tap(activityBackButtonFinder);
      await tester.pumpAndSettle();
      expect(activityTimepillarCardFinder, findsOneWidget);
    });

    testWidgets('Full day activity page does not show edit alarm',
        (WidgetTester tester) async {
      mockActivityDb.initWithActivity(FakeActivity.fullDay(startTime));
      await navigateToFullDayActivityPage(tester);
      expect(alarmButtonFinder, findsNothing);
    });

    testWidgets('Speech buttons are visible when available',
        (WidgetTester tester) async {
      final activityWithStartAndEndSpeech = Activity.createNew(
        title: 'title',
        startTime: startTime,
        extras: Extras.createNew(
          startTimeExtraAlarm: UnstoredAbiliaFile.forTest(
            'id',
            'path',
            File('test.mp3'),
          ),
          endTimeExtraAlarm: UnstoredAbiliaFile.forTest(
            'id',
            'path',
            File('test.mp3'),
          ),
        ),
      );
      mockActivityDb.initWithActivity(activityWithStartAndEndSpeech);
      await navigateToActivityPage(tester);
      expect(find.byType(PlaySoundButton), findsNWidgets(2));
    });

    testWidgets('Only one speech button visible when only one speech enabled',
        (WidgetTester tester) async {
      final activityWithStartAndEndSpeech = Activity.createNew(
        title: 'title',
        startTime: startTime,
        extras: Extras.createNew(
          endTimeExtraAlarm: UnstoredAbiliaFile.forTest(
            'id',
            'path',
            File('test.mp3'),
          ),
        ),
      );
      mockActivityDb.initWithActivity(activityWithStartAndEndSpeech);
      await navigateToActivityPage(tester);
      expect(find.byType(PlaySoundButton), findsOneWidget);
    });

    testWidgets('Youtube video is shown when UrlInfoItem url is a youtube link',
        (WidgetTester tester) async {
      const url = 'https://www.youtube.com/watch?v=A_LWGAOBy04';

      mockActivityDb.initWithActivity(Activity.createNew(
        title: 'title',
        startTime: startTime,
        infoItem: const UrlInfoItem(url),
      ));

      await navigateToActivityPage(tester);
      expect(find.byType(YoutubePlayer), findsOneWidget);
    });

    testWidgets(
        'When edit an activity and it is deleted from myabilia, pop back to CalendarPage',
        (WidgetTester tester) async {
      // Arrange
      final pushCubit = PushCubit();
      final activity = FakeActivity.starts(startTime);
      mockActivityDb.initWithActivity(activity);

      // Act - Open edit activity
      await tester.pumpWidget(App(pushCubit: pushCubit));
      await tester.pumpAndSettle();
      await tester.tap(activityTimepillarCardFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EditActivityButton));
      await tester.pumpAndSettle();

      // Act - Add deleted to activity and make a fake push.
      // Activity response is not empty so SyncBloc will emit a new state.
      mockActivityDb.insertAndAddDirty([activity.copyWith(deleted: true)]);
      activityResponse = () => [Activity.createNew(startTime: startTime)];
      pushCubit.fakePush();
      await tester.pumpAndSettle();

      // Assert - Back at calendar page
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets(
        'When edit a recurring fullday activity from FullDayActivityList '
        'and it is deleted from myabilia, pop back to closest ActivityRootPage',
        (WidgetTester tester) async {
      // Arrange
      final pushCubit = PushCubit();
      final activities = [
        FakeActivity.fullDay(startTime, 'one', Recurs.everyDay),
        FakeActivity.fullDay(startTime, 'two', Recurs.everyDay),
      ];
      mockActivityDb.initWithActivities(activities);

      // Act - Open full day list page
      await tester.pumpWidget(App(pushCubit: pushCubit));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FullDayStack).first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FullDayListPage), findsOneWidget);

      // Act - Open first activity and edit it
      await tester.tap(find.text(activities[0].title));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EditActivityButton));
      await tester.pumpAndSettle();

      // Act - Remove first activity and make a fake push.
      mockActivityDb.initWithActivity(activities[1]);
      activityResponse = () => [Activity.createNew(startTime: startTime)];
      pushCubit.fakePush();
      await tester.pumpAndSettle();

      // Assert - Back at full day list page
      expect(find.byType(FullDayListPage), findsOneWidget);

      // Act - Open second activity and edit it
      await tester.tap(find.text(activities[1].title));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EditActivityButton));
      await tester.pumpAndSettle();

      // Act - Remove second activity and make a fake push.
      mockActivityDb.clear();
      activityResponse = () => [Activity.createNew(startTime: startTime)];
      pushCubit.fakePush();
      await tester.pumpAndSettle();

      // Assert - Back at calendar page
      expect(find.byType(FullDayListPage), findsNothing);
      expect(find.byType(CalendarPage), findsOneWidget);
    });
  });

  group('Edit activity', () {
    final editActivityPageFinder = find.byType(EditActivityPage);
    final titleTextFormFieldFinder = find.byKey(TestKey.editTitleTextFormField);

    testWidgets('Edit activity button shows', (WidgetTester tester) async {
      // Arrange
      mockActivityDb.insert([FakeActivity.starts(startTime).wrapWithDbModel()]);
      // Act
      await navigateToActivityPage(tester);
      // Assert -- Find the edit activity button
      expect(editActivityButtonFinder, findsOneWidget);
    });

    testWidgets('Can open edit activity page', (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      await navigateToActivityPage(tester);
      // Act -- tap the edit activity button
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      // Assert -- edit activity shows
      expect(editActivityPageFinder, findsOneWidget);
    });

    testWidgets('Correct activity shows in edit activity',
        (WidgetTester tester) async {
      // Arrange
      const title = 'an interesting title';
      mockActivityDb.initWithActivity(
          FakeActivity.starts(startTime).copyWith(title: title));
      await navigateToActivityPage(tester);

      // Act -- tap the edit activity button
      expect(find.text(title), findsOneWidget);
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- edit activity title is same as activity title
      expect(editActivityPageFinder, findsOneWidget);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('Changes in edit activity shows in activity page',
        (WidgetTester tester) async {
      // Arrange
      const title = 'an interesting title';
      const newTitle = 'an new super interesting title';
      final activity = FakeActivity.starts(startTime).copyWith(title: title);
      mockActivityDb.initWithActivity(activity);
      await navigateToActivityPage(tester);

      // Assert -- original title
      expect(find.text(title), findsOneWidget);

      // Act -- tap edit activity button
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- that the old title is there
      expect(titleTextFormFieldFinder, findsOneWidget);
      expect(find.text(title), findsOneWidget);

      // Act -- Enter new title and save
      await tester.ourEnterText(titleTextFormFieldFinder, newTitle);
      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle(2.seconds());

      // Assert -- we are at activity page, the old title is not there, the new title is
      expect(find.text(title), findsNothing);
      expect(activityPageFinder, findsOneWidget);
      expect(find.text(newTitle), findsOneWidget);
    });

    Future changeDate(WidgetTester tester, int day) async {
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(
        find.ancestor(
            of: find.text('$day'),
            matching: find.byKey(TestKey.monthCalendarDay)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'Change date in edit activity shows in activity page for non recurring activities',
        (WidgetTester tester) async {
      // Arrange
      const day = 14;
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      await navigateToActivityPage(tester);

      expect(find.textContaining('11 November 2111'), findsOneWidget);
      final appBar = find.byType(CalendarAppBar);
      final theme = tester.widget<AnimatedTheme>(
          find.descendant(of: appBar, matching: find.byType(AnimatedTheme)));
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      await changeDate(tester, day);

      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      final newTheme = tester.widget<AnimatedTheme>(
          find.descendant(of: appBar, matching: find.byType(AnimatedTheme)));

      expect(find.text('$day November 2111'), findsOneWidget);
      expect(
          theme.data.scaffoldBackgroundColor ==
              newTheme.data.scaffoldBackgroundColor,
          false);
    });

    testWidgets(
        'Change date in edit activity show in activity page for recurring activities',
        (WidgetTester tester) async {
      // Arrange
      const day = 14;
      mockActivityDb.initWithActivity(FakeActivity.reoccursEveryDay(startTime));

      await navigateToActivityPage(tester);

      expect(find.textContaining('11 November 2111'), findsOneWidget);
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      await changeDate(tester, day);

      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      expect(find.byType(SelectRecurrentTypePage), findsOneWidget);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      // text change stands
      expect(find.textContaining('11 November 2111'), findsNothing);
      expect(find.text('$day November 2111'), findsOneWidget);
    });

    testWidgets(
        'Change date for recurring activities only option is Only this day',
        (WidgetTester tester) async {
      // Arrange
      const day = 19;
      mockActivityDb.initWithActivity(FakeActivity.reoccursEveryDay(startTime));
      await navigateToActivityPage(tester);

      expect(find.textContaining('11 November 2111'), findsOneWidget);
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      await changeDate(tester, day);

      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      expect(find.byType(SelectRecurrentTypePage), findsOneWidget);
      expect(find.byKey(TestKey.onlyThisDay), findsOneWidget);
      expect(find.byKey(TestKey.allDays), findsNothing);
      expect(find.byKey(TestKey.thisDayAndForward), findsNothing);
    });

    testWidgets(
        'SGC-934 Change date for past activity to future updates Occasion state (no cross over)',
        (WidgetTester tester) async {
      final toDay = startTime.day;
      // Arrange
      mockActivityDb.initWithActivity(Activity.createNew(
        startTime: startTime.subtract(1.days()).add(1.minutes()),
        title: 'a title for activity',
      ));

      // Act -- go back one day and open activity
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();
      await tester.tap(activityTimepillarCardFinder);
      await tester.pumpAndSettle();

      // Assert -- is past, crossover showing and no sideDots showing
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.ancestor(
                of: find.byType(CrossOver),
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .opacity,
        1.0,
      );
      expect(find.byType(SideDotsLarge), findsNothing);

      // Act --  edit activity date to today and save
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      await changeDate(tester, toDay);
      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      // Assert -- we are at activity page, cross over is gone and side time dots visible
      expect(activityPageFinder, findsOneWidget);
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.ancestor(
                of: find.byType(CrossOver),
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .opacity,
        0.0,
      );
      expect(find.byType(SideDotsLarge), findsOneWidget);
    });
  });

  group('Change alarm', () {
    final alarmDialogFinder = find.byType(SelectAlarmPage);
    final vibrationRadioButtonFinder =
        find.byKey(const ObjectKey(AlarmType.vibration));
    final noAlarmIconFinder = find.byIcon(AbiliaIcons.handiNoAlarmVibration);
    final vibrateAlarmIconFinder = find.byIcon(AbiliaIcons.handiVibration);
    final soundVibrateAlarmIconFinder =
        find.byIcon(AbiliaIcons.handiAlarmVibration);

    testWidgets('Alarm view dialog shows', (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      await navigateToActivityPage(tester);
      // Act
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      // Assert
      expect(alarmDialogFinder, findsOneWidget);
    });

    testWidgets('Alarm button shows correct icon vibration',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(
          FakeActivity.starts(startTime).copyWith(alarmType: alarmVibration));

      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(vibrateAlarmIconFinder, findsOneWidget);
    });

    testWidgets(
        'Past activity with image does not show crossover over the image',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        // Arrange
        mockActivityDb.initWithActivity(
          Activity.createNew(
            startTime: startTime.subtract(1.hours()),
            fileId: 'fileId',
          ),
        );
        // Act
        await navigateToActivityPage(tester);

        // Assert - CrossOver only over AppBar and start time
        expect(find.byType(CrossOver), findsNWidgets(2));
        expect(
          find.descendant(
            of: find.byType(EventImage),
            matching: find.byType(CrossOver),
          ),
          findsNothing,
        );
      });
    });
    testWidgets('Alarm button shows correct icon sound and vibration',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime)
          .copyWith(alarmType: alarmSoundAndVibrationOnlyOnStart));
      FakeActivity.starts(startTime).copyWith(alarmType: alarmVibration);

      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(soundVibrateAlarmIconFinder, findsOneWidget);
    });

    testWidgets('Alarm button shows correct icon no alarm',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(
          FakeActivity.starts(startTime).copyWith(alarmType: noAlarm));
      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(noAlarmIconFinder, findsOneWidget);
    });

    testWidgets('Alarm button changes alarm correct icon',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(
          FakeActivity.starts(startTime).copyWith(alarmType: noAlarm));

      // Act
      await navigateToActivityPage(tester);
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(vibrationRadioButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(noAlarmIconFinder, findsNothing);
      expect(vibrateAlarmIconFinder, findsOneWidget);
    });

    testWidgets('SGC-359 Alarm type maps Only alarm to SoundAndVibration',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(Activity.createNew(
        title: 'null',
        startTime: startTime,
        alarmType: alarmSound,
      ));

      await navigateToActivityPage(tester);
      // Act
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      // Assert
      expect(alarmDialogFinder, findsOneWidget);

      final alarm = tester.widget<RadioField>(
        find.byKey(
          const ObjectKey(AlarmType.soundAndVibration),
        ),
      );

      expect(alarm.groupValue, AlarmType.soundAndVibration);
    });

    testWidgets('SGC-359 Alarm type maps ALARM_SILENT to Silent',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(Activity.createNew(
        title: 'null',
        startTime: startTime,
        alarmType: alarmSilent,
      ));

      await navigateToActivityPage(tester);
      // Act
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      // Assert
      expect(alarmDialogFinder, findsOneWidget);

      final alarm = tester.widget<RadioField>(
        find.byKey(
          const ObjectKey(AlarmType.silent),
        ),
      );

      expect(alarm.groupValue, AlarmType.silent);
    });

    testWidgets('Alarm on start time is disabled when no alarm',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(
          FakeActivity.starts(startTime).copyWith(alarmType: noAlarm));

      // Act
      await navigateToActivityPage(tester);
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- alarm At Start Switch and ok button is disabled
      expect(
          tester
              .widget<MemoplannerSwitch>(
                  find.byKey(const ObjectKey(TestKey.alarmAtStartSwitch)))
              .onChanged,
          isNull);
    });

    testWidgets('Alarm on start time changes', (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime)
          .copyWith(alarmType: alarmSoundAndVibrationOnlyOnStart));

      // Act
      await navigateToActivityPage(tester);
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(alarmAtStartSwitchFinder);
      await tester.pumpAndSettle();

      // Assert -- ok button is enabled
      expect(tester.widget<OkButton>(okButtonFinder).onPressed, isNotNull);
    });

    testWidgets(
        'Changing alarm on single instance should not show apply to dialog',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.insertAndAddDirty(FakeActivity.singleInstance(startTime));
      await navigateToActivityPage(tester);

      // Act
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(alarmAtStartSwitchFinder);
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SelectRecurrentTypePage), findsNothing);
    });

    testWidgets(
        'Changing alarm and clicking cancel triggers discard warning dialog',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(
          FakeActivity.starts(startTime).copyWith(alarmType: noAlarm));

      // Act
      await navigateToActivityPage(tester);
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(vibrationRadioButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(cancelButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DiscardWarningDialog), findsOneWidget);
    });
  });

  group('Delete activity', () {
    testWidgets('Finds delete button and no delete app bar',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));

      // Act
      await navigateToActivityPage(tester);

      // Assert
      expect(deleteButtonFinder, findsOneWidget);
      expect(yesNoDialogFinder, findsNothing);
      expect(okInkWellFinder, findsNothing);
    });

    testWidgets('When delete button pressed Delete Activity Dialog is showing',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      await navigateToActivityPage(tester);

      // Act
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(yesNoDialogFinder, findsOneWidget);
      expect(yesButtonFinder, findsOneWidget);
    });

    testWidgets('When cancel pressed, nothing happens',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      await navigateToActivityPage(tester);

      // Act
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(noButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(deleteButtonFinder, findsOneWidget);
      expect(yesNoDialogFinder, findsNothing);
      expect(okInkWellFinder, findsNothing);
    });

    testWidgets(
        'When delete then confirm delete pressed, '
        'navigate back and do not show original widget',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      await navigateToActivityPage(tester);

      // Act
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(yesButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(deleteButtonFinder, findsNothing);
      expect(yesNoDialogFinder, findsNothing);
      expect(yesButtonFinder, findsNothing);
      expect(activityTimepillarCardFinder, findsNothing);
      expect(activityPageFinder, findsNothing);
      expect(timepillarFinder, findsOneWidget);
    });

    testWidgets(
        'When delete button pressed Delete recurring is not showing for single instance',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.insertAndAddDirty(FakeActivity.singleInstance(startTime));
      await navigateToActivityPage(tester);

      // Act
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(yesButtonFinder);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(SelectRecurrentTypePage), findsNothing);
    });

    testWidgets(
        'SGC-1709 When delete button pressed for single recurring with start date equal to end date No this day and forward question shown',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivity(
        Activity.createNew(
            title: 'title',
            startTime: (startTime),
            recurs: Recurs.raw(
              Recurs.typeWeekly,
              Recurs.allDaysOfWeek,
              startTime.millisecondsSinceEpoch,
            ),
            alarmType: alarmSilent),
      );
      await navigateToActivityPage(tester);

      // Act
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(yesButtonFinder);
      await tester.pumpAndSettle();
      // // Assert
      expect(find.byType(SelectRecurrentTypePage), findsNothing);
    });
  });
  group('Edit recurring', () {
    final editRecurrentFinder = find.byType(SelectRecurrentTypePage);
    final onlyThisDayRadioFinder =
        find.byKey(const ObjectKey(TestKey.onlyThisDay));
    final allDaysRadioFinder = find.byKey(const ObjectKey(TestKey.allDays));
    final thisDayAndForwardRadioFinder =
        find.byKey(const ObjectKey(TestKey.thisDayAndForward));

    group('Delete recurring', () {
      testWidgets('Deleting recurring should show apply to dialog',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(editRecurrentFinder, findsOneWidget);
      });

      testWidgets(
          'Does not delete activity when not pressing confirm on recurring delete dialog',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(cancelButtonFinder);
        await tester.pumpAndSettle();

        // Assert -- Still on activity page
        expect(activityPageFinder, findsOneWidget);
      });

      testWidgets(
          'When delete recurring activity then show '
          'three alternatives for deletion', (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(onlyThisDayRadioFinder, findsOneWidget);
        expect(allDaysRadioFinder, findsOneWidget);
        expect(thisDayAndForwardRadioFinder, findsOneWidget);
      });

      testWidgets('When delete recurring the chosen alternative is onlyThisDay',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 =
            tester.widget<AbiliaRadio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<AbiliaRadio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<AbiliaRadio>(thisDayAndForwardRadioFinder);

        // Assert
        expect(onlyThisDayRadio1.value, ApplyTo.onlyThisDay);
        expect(allDaysRadio1.value, ApplyTo.allDays);
        expect(thisDayAndForwardRadio1.value, ApplyTo.thisDayAndForward);

        expect(onlyThisDayRadio1.groupValue, ApplyTo.onlyThisDay);
        expect(allDaysRadio1.groupValue, ApplyTo.onlyThisDay);
        expect(thisDayAndForwardRadio1.groupValue, ApplyTo.onlyThisDay);
      });

      testWidgets('When delete recurring tapping All days',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(allDaysRadioFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 =
            tester.widget<AbiliaRadio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<AbiliaRadio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<AbiliaRadio>(thisDayAndForwardRadioFinder);

        // Assert
        expect(onlyThisDayRadio1.groupValue, ApplyTo.allDays);
        expect(allDaysRadio1.groupValue, ApplyTo.allDays);
        expect(thisDayAndForwardRadio1.groupValue, ApplyTo.allDays);
      });

      testWidgets('When delete recurring tapping This day and forward',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(thisDayAndForwardRadioFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 =
            tester.widget<AbiliaRadio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<AbiliaRadio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<AbiliaRadio>(thisDayAndForwardRadioFinder);

        // Assert
        expect(onlyThisDayRadio1.groupValue, ApplyTo.thisDayAndForward);
        expect(allDaysRadio1.groupValue, ApplyTo.thisDayAndForward);
        expect(thisDayAndForwardRadio1.groupValue, ApplyTo.thisDayAndForward);
      });

      testWidgets(
          'When delete recurring and confirm Only this day, '
          'navigate back and do not show original widget',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(deleteButtonFinder, findsNothing);
        expect(yesNoDialogFinder, findsNothing);
        expect(okButtonFinder, findsNothing);
        expect(activityTimepillarCardFinder, findsNothing);
        expect(activityPageFinder, findsNothing);
        expect(timepillarFinder, findsOneWidget);
      });

      final goToNextPageFinder = find.byIcon(AbiliaIcons.goToNextPage);
      final goToPreviousPageFinder =
          find.byIcon(AbiliaIcons.returnToPreviousPage);
      testWidgets(
          'When delete recurring and confirm Only this day, '
          'go to next day and previous day shows activity card',
          (WidgetTester tester) async {
        // Arrange
        const title = 'Unique title to search for';
        mockActivityDb.initWithActivity(
            FakeActivity.reoccursEveryDay(tenDaysAgo).copyWith(title: title));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityTimepillarCardFinder, findsOneWidget);
        expect(find.text(title), findsOneWidget);

        // Act -- to to yesterday
        await tester.tap(goToPreviousPageFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToPreviousPageFinder);
        await tester.pumpAndSettle();

        expect(activityTimepillarCardFinder, findsOneWidget);
        expect(find.text(title), findsOneWidget);
      });

      testWidgets(
          'When delete recurring a confirm all days, go to previous day and next day shows no activity card',
          (WidgetTester tester) async {
        // Arrange
        const title = 'Unique title to search for';
        mockActivityDb.initWithActivity(
            FakeActivity.reoccursEveryDay(startTime).copyWith(title: title));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(allDaysRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToPreviousPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityTimepillarCardFinder, findsNothing);
        expect(find.text(title), findsNothing);

        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityTimepillarCardFinder, findsNothing);
        expect(find.text(title), findsNothing);
      });

      testWidgets(
          'When delete recurring and confirming This day and forward, this day and next day does not shows activity card but previous day does',
          (WidgetTester tester) async {
        // Arrange
        const title = 'Unique title to search for';
        mockActivityDb.initWithActivity(
            FakeActivity.reoccursEveryDay(tenDaysAgo).copyWith(title: title));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(thisDayAndForwardRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityTimepillarCardFinder, findsNothing);
        expect(find.text(title), findsNothing);

        // Act -- go to yesterday
        await tester.tap(goToPreviousPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityTimepillarCardFinder, findsOneWidget);
        expect(find.text(title), findsOneWidget);

        // Act -- go to tomorrow
        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityTimepillarCardFinder, findsNothing);
        expect(find.text(title), findsNothing);
      });
    });

    group('Edit recurring alarm', () {
      testWidgets('Changing alarm on recurring should show apply to dialog',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(alarmButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(alarmAtStartSwitchFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(editRecurrentFinder, findsOneWidget);
      });
    });

    group('Edit recurring Activity', () {
      final titleTextFormFieldFinder =
          find.byKey(TestKey.editTitleTextFormField);
      testWidgets('Edit an recurring should show Apply to dialog when edited',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.ourEnterText(
            find.byKey(TestKey.editTitleTextFormField), 'new title');
        await tester.pumpAndSettle();
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(editRecurrentFinder, findsOneWidget);
      });

      testWidgets('Edit an recurring Only this days shows changes',
          (WidgetTester tester) async {
        // Arrange
        mockActivityDb
            .initWithActivity(FakeActivity.reoccursEveryDay(startTime));
        await navigateToActivityPage(tester);
        const newTitle = 'newTitle';

        // Act
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.ourEnterText(titleTextFormFieldFinder, newTitle);
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(newTitle), findsOneWidget);
      });

      testWidgets(
          'Correct day in DatePicker shows in edit activity when edit recurring activity',
          (WidgetTester tester) async {
        // Arrange
        final activity = Activity.createNew(
          title: 'title',
          startTime: startTime.subtract(100.days()),
          recurs: Recurs.weeklyOnDays(const [1, 2, 3, 4, 5, 6, 7]),
        );
        mockActivityDb.initWithActivity(activity);
        await navigateToActivityPage(tester);

        // Act -- tap the edit activity button
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();

        // Assert -- edit activity date is same as picked day
        expect(find.byType(EditActivityPage), findsOneWidget);
        final datePickerDate =
            tester.widget<DatePicker>(find.byType(DatePicker)).date;
        expect(datePickerDate.onlyDays(), startTime.onlyDays());
      });

      testWidgets('No edit on recurring activity does not show apply to pop up',
          (WidgetTester tester) async {
        // Arrange
        final activity = Activity.createNew(
          title: 'title',
          startTime: startTime.subtract(100.days()),
          recurs: Recurs.weeklyOnDays(const [1, 2, 3, 4, 5, 6, 7]),
        );
        mockActivityDb.initWithActivity(activity);
        await navigateToActivityPage(tester);

        // Act -- tap the edit activity button
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();

        // Assert -- we are back on activity page
        expect(activityPageFinder, findsOneWidget);
      });

      testWidgets('Edit an recurring This day and forward shows changes',
          (WidgetTester tester) async {
        // Arrange
        const newTitle = 'new Title', oldTitle = 'old title';
        mockActivityDb.initWithActivity(Activity.createNew(
          title: oldTitle,
          startTime: startTime.subtract(100.days()),
          recurs: Recurs.weeklyOnDays(const [1, 2, 3, 4, 5, 6, 7]),
        ));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.ourEnterText(titleTextFormFieldFinder, newTitle);
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();
        await tester.tap(thisDayAndForwardRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(newTitle), findsOneWidget);
      });
    });
  });

  testWidgets('Checklist attachment can be signed off',
      (WidgetTester tester) async {
    const tag = 'tag';
    final activity = Activity.createNew(
        title: 'title',
        startTime: startTime,
        infoItem: Checklist(questions: const [
          Question(id: 0, name: tag),
          Question(id: 1, name: 'another'),
        ]));

    // Arrange
    mockActivityDb.initWithActivity(activity);
    await navigateToActivityPage(tester);

    // Assert no checklist item is checked
    tester.widgetList(find.byType(QuestionView)).forEach((element) {
      if (element is QuestionView) {
        expect(element.signedOff, isFalse);
      }
    });

    // Act tap question "tag"
    await tester.tap(find.text(tag));
    await tester.pumpAndSettle();

    // Assert "tag" is checked
    final allQuestionViews = tester.widgetList(find.byType(QuestionView));
    expect(allQuestionViews, hasLength(2));
    for (final element in allQuestionViews) {
      if (element is QuestionView) {
        if (element.question.name == tag) {
          expect(element.signedOff, isTrue);
        } else {
          expect(element.signedOff, isFalse);
        }
      }
    }
  });

  testWidgets(
      'SGC-1736 Check all checklist in checkable activity shows sign off question',
      (WidgetTester tester) async {
    const tag1 = 'tag', tag2 = 'another';
    final activity = Activity.createNew(
        title: 'title',
        startTime: startTime,
        checkable: true,
        infoItem: Checklist(questions: const [
          Question(id: 0, name: tag1),
          Question(id: 1, name: tag2),
        ]));

    // Arrange
    mockActivityDb.initWithActivity(activity);
    await navigateToActivityPage(tester);

    // Act sign off question
    await tester.tap(find.text(tag1));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tag2));
    await tester.pumpAndSettle();

    // Assert pop up with signed off all question shows
    expect(find.byType(CheckActivityConfirmDialog), findsOneWidget);
  });

  testWidgets('Check and uncheck activity with confirmation',
      (WidgetTester tester) async {
    mockActivityDb.initWithActivity(
        FakeActivity.starts(startTime).copyWith(checkable: true));

    await navigateToActivityPage(tester);
    expect(checkButtonFinder, findsOneWidget);
    expect(uncheckButtonFinder, findsNothing);
    await tester.tap(checkButtonFinder);
    await tester.pumpAndSettle();

    expect(noButtonFinder, findsOneWidget);
    await tester.tap(noButtonFinder);
    await tester.pumpAndSettle();

    expect(checkButtonFinder, findsOneWidget);
    expect(uncheckButtonFinder, findsNothing);

    await tester.tap(checkButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(yesButtonFinder);
    await tester.pumpAndSettle();

    expect(checkButtonFinder, findsNothing);
    expect(uncheckButtonFinder, findsOneWidget);

    await tester.tap(uncheckButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(yesButtonFinder);
    await tester.pumpAndSettle();

    expect(checkButtonFinder, findsOneWidget);
    expect(uncheckButtonFinder, findsNothing);
  });

  group('Memoplanner settings', () {
    testWidgets('Do not display delete button when setting is false',
        (WidgetTester tester) async {
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          <Generic>[
            genericSetting(false, ActivityViewSettings.displayDeleteButtonKey)
          ],
        ),
      );
      await navigateToActivityPage(tester);
      expect(deleteButtonFinder, findsNothing);
      expect(editActivityButtonFinder, findsOneWidget);
      expect(alarmButtonFinder, findsOneWidget);
    });

    testWidgets('Do not display any button when all settings are false',
        (WidgetTester tester) async {
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          <Generic>[
            genericSetting(false, ActivityViewSettings.displayDeleteButtonKey),
            genericSetting(false, ActivityViewSettings.displayAlarmButtonKey),
            genericSetting(false, ActivityViewSettings.displayEditButtonKey),
          ],
        ),
      );
      await navigateToActivityPage(tester);
      expect(deleteButtonFinder, findsNothing);
      expect(editActivityButtonFinder, findsNothing);
      expect(alarmButtonFinder, findsNothing);
    });

    testWidgets('Do not display side dots when setting is false',
        (WidgetTester tester) async {
      mockActivityDb.initWithActivity(FakeActivity.starts(startTime));
      when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          <Generic>[
            genericSetting(false, ActivityViewSettings.displayQuarterHourKey),
          ],
        ),
      );
      await navigateToActivityPage(tester);
      expect(activityInfoSideDotsFinder, findsNothing);
    });
  });
  group('tts', () {
    testWidgets('heading', (WidgetTester tester) async {
      mockActivityDb.initWithActivity(
          Activity.createNew(title: 'title', startTime: startTime));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byType(AppBar), contains: 'Wednesday');
    });

    testWidgets('title', (WidgetTester tester) async {
      const title = 'generic title';
      mockActivityDb.initWithActivity(
          Activity.createNew(title: title, startTime: startTime));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.text(title), exact: title);
    });

    testWidgets('start time', (WidgetTester tester) async {
      const expectedTts = '11:11 AM';
      mockActivityDb.initWithActivity(
          Activity.createNew(title: 'title', startTime: startTime));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byKey(TestKey.startTime), exact: expectedTts);
    });

    testWidgets('end time', (WidgetTester tester) async {
      const expectedTts = '3:11 PM';
      mockActivityDb.initWithActivity(Activity.createNew(
        title: 'title',
        startTime: startTime.add(2.hours()),
        duration: 2.hours(),
      ));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byKey(TestKey.endTime), exact: expectedTts);
    });

    testWidgets('note', (WidgetTester tester) async {
      const noteText =
          '''In accordance with the Christmas traditions of the Serbs, their festive meal has a copious and diverse selection of foods, although it is prepared according to the rules of fasting.
As well as a round, unleavened loaf of bread and salt, which are necessary, this meal may comprise roast fish, cooked beans, sauerkraut, noodles with ground walnuts, honey, and wine.
Families in some Slavic countries leave an empty place at the table for guests (alluding to Mary and Joseph looking for shelter in Bethlehem).
''';
      mockActivityDb.initWithActivity(Activity.createNew(
        title: 'title',
        startTime: startTime,
        infoItem: const NoteInfoItem(noteText),
      ));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byType(NoteBlock), exact: noteText);
    });

    testWidgets('checklist', (WidgetTester tester) async {
      const item1 = 'first thing on the list';
      mockActivityDb.initWithActivity(Activity.createNew(
        title: 'title',
        startTime: startTime,
        infoItem: Checklist(questions: const [Question(id: 1, name: item1)]),
      ));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byType(QuestionView), exact: item1);
    });

    testWidgets('timepillar left to start', (WidgetTester tester) async {
      const expectedTts = '2 h\n2 min';
      mockActivityDb.initWithActivity(Activity.createNew(
        title: 'title',
        startTime: startTime.add(2.hours() + 2.minutes()),
        duration: 2.hours(),
      ));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byKey(TestKey.sideDotsTimeText),
          contains: expectedTts);
    });

    testWidgets('check button', (WidgetTester tester) async {
      const title = 'just some title';
      mockActivityDb.initWithActivity(Activity.createNew(
          title: title, startTime: startTime, checkable: true));

      await navigateToActivityPage(tester);
      expect(checkButtonFinder, findsOneWidget);
      expect(uncheckButtonFinder, findsNothing);
      await tester.verifyTts(checkButtonFinder, exact: translate.check);
      await tester.tap(checkButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(yesButtonFinder);
      await tester.pumpAndSettle();
      expect(uncheckButtonFinder, findsOneWidget);
    });

    testWidgets('delete activity', (WidgetTester tester) async {
      const title = 'just some title';
      mockActivityDb.initWithActivity(Activity.createNew(
          title: title, startTime: startTime, checkable: true));

      await navigateToActivityPage(tester);
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();
      await tester.verifyTts(find.text(translate.delete),
          exact: translate.delete);
      await tester.verifyTts(find.text(translate.deleteActivityQuestion),
          exact: translate.deleteActivityQuestion);
    });

    testWidgets('alarms', (WidgetTester tester) async {
      const title = 'just some title';
      mockActivityDb.initWithActivity(
        Activity.createNew(
          title: title,
          startTime: startTime,
          checkable: true,
          alarmType: alarmVibration,
        ),
      );

      await navigateToActivityPage(tester);
      // Act -- tap reminder button
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- tts
      await tester.verifyTts(
        find.byKey(const ObjectKey(AlarmType.soundAndVibration)),
        exact: translate.alarmAndVibration,
      );
      await tester.verifyTts(
        find.byKey(const ObjectKey(AlarmType.vibration)),
        exact: translate.vibrationIfAvailable,
      );
      await tester.verifyTts(
        find.byIcon(AbiliaIcons.handiNoAlarmVibration),
        exact: translate.noAlarm,
      );

      await tester.verifyTts(
        find.byKey(TestKey.alarmAtStartSwitch),
        exact: translate.alarmOnlyAtStartTime,
      );
    });
  });
}
