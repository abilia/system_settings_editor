import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:seagull/background/all.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);
  final day = startTime.onlyDays();
  const userFile = UserFile(
    id: 'id',
    sha1: 'sha1',
    md5: 'md5',
    path: 'test.mp3',
    fileSize: 1234,
    deleted: false,
    fileLoaded: true,
  );

  final speechFile = UnstoredAbiliaFile.forTest(
    userFile.id,
    userFile.path,
    File(userFile.path),
  );

  final activityWithStartSpeech = Activity.createNew(
    title: 'title',
    startTime: startTime,
    extras: Extras.createNew(
      startTimeExtraAlarm: speechFile,
    ),
  );

  final activityWithStartAndEndSpeech = Activity.createNew(
    title: 'title',
    startTime: startTime,
    extras: Extras.createNew(
      startTimeExtraAlarm: speechFile,
      endTimeExtraAlarm: speechFile,
    ),
  );

  final StartAlarm startAlarm = StartAlarm(
    ActivityDay(activityWithStartSpeech, day),
  );
  final EndAlarm endAlarmWithNoSpeech = EndAlarm(
    ActivityDay(activityWithStartSpeech, day),
  );
  final EndAlarm endAlarmWithSpeech = EndAlarm(
    ActivityDay(activityWithStartAndEndSpeech, day),
  );
  final alarmNavigator = AlarmNavigator();
  late MockMemoplannerSettingBloc mockMPSettingsBloc;
  late StreamController<MemoplannerSettingsState> mockMPSettingsBlocStream;
  late MockUserFileCubit mockUserFileCubit;

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: RepositoryProvider<ActivityRepository>(
          create: (context) => FakeActivityRepository(),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ActivitiesBloc>(
                create: (context) => FakeActivitiesBloc(),
              ),
              BlocProvider<ClockBloc>(
                create: (context) => ClockBloc.fixed(day),
              ),
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
              ),
              BlocProvider<MemoplannerSettingBloc>(
                create: (context) => mockMPSettingsBloc,
              ),
              BlocProvider<UserFileCubit>(
                create: (context) => mockUserFileCubit,
              ),
              BlocProvider<TouchDetectionCubit>(
                create: (context) => TouchDetectionCubit(),
              ),
              BlocProvider<AlarmCubit>(
                create: (context) => FakeAlarmCubit(),
              ),
              BlocProvider<TimepillarMeasuresCubit>(
                create: (context) => FakeTimepillarMeasuresCubit(),
              ),
              BlocProvider<TimepillarCubit>(
                create: (context) => FakeTimepillarCubit(),
              ),
              BlocProvider<DayPartCubit>(
                create: (context) => FakeDayPartCubit(),
              ),
              BlocProvider<LicenseCubit>(
                create: (context) => FakeLicenseCubit(),
              ),
            ],
            child: Builder(
              builder: (context) => Listener(
                onPointerDown:
                    context.read<TouchDetectionCubit>().onPointerDown,
                child: widget,
              ),
            ),
          ),
        ),
      );

  setUpAll(() {
    registerFallbackValues();
  });

  const MethodChannel localNotificationChannel =
      MethodChannel('dexterous.com/flutter/local_notifications');
  const MethodChannel audioPlayerChannel =
      MethodChannel('xyz.luan/audioplayers');
  final List<MethodCall> localNotificationLog = <MethodCall>[];
  final List<MethodCall> audioLog = <MethodCall>[];

  setUp(() async {
    localNotificationLog.clear();
    localNotificationChannel.setMockMethodCallHandler((methodCall) async {
      localNotificationLog.add(methodCall);
      if (methodCall.method == 'getActiveNotifications') {
        return null;
      }
    });
    audioLog.clear();
    audioPlayerChannel.setMockMethodCallHandler((methodCall) async {
      audioLog.add(methodCall);
      if (methodCall.method == 'play') {
        return Future.value(1);
      }
    });

    mockUserFileCubit = MockUserFileCubit();
    when(() => mockUserFileCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    mockUserFileCubit = MockUserFileCubit();
    when(() => mockUserFileCubit.state)
        .thenReturn(const UserFilesLoaded([userFile]));
    mockMPSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMPSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
            MemoplannerSettings(alarm: AlarmSettings(durationMs: 0))));
    mockMPSettingsBlocStream = StreamController<MemoplannerSettingsState>();
    final settingsStream = mockMPSettingsBlocStream.stream.asBroadcastStream();
    when(() => mockMPSettingsBloc.stream).thenAnswer((_) => settingsStream);
    await initializeDateFormatting();
    // ticker = ;
    GetItInitializer()
      ..fileStorage = FakeFileStorage()
      ..database = FakeDatabase()
      ..ticker = Ticker.fake(initialTime: startTime)
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
    clearNotificationSubject();
    mockMPSettingsBlocStream.close();
  });

  group('alarm speech', () {
    group('button tests', () {
      testWidgets('Alarm page visible', (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: alarmNavigator,
              child: AlarmPage(
                alarm: startAlarm,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
        expect(find.byType(AlarmPage), findsOneWidget);
      });

      testWidgets('Start alarm shows play speech button',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: alarmNavigator,
              child: AlarmPage(alarm: startAlarm),
            ),
          ),
        );
        await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
        expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
      });

      testWidgets(
        'Ongoing Start alarm shows play speech button',
        (WidgetTester tester) async {
          final fullscreenStartAlarm = StartAlarm(
            startAlarm.activityDay,
            fullScreenActivity: true,
          );
          tester.binding.window.physicalSizeTestValue = const Size(800, 1280);
          tester.binding.window.devicePixelRatioTestValue = 1;

          // resets the screen to its orinal size after the test end
          addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
          addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
          await tester.pumpWidget(
            wrapWithMaterialApp(
              PopAwareAlarmPage(
                alarm: fullscreenStartAlarm,
                alarmNavigator: alarmNavigator,
                child: AlarmPage(alarm: fullscreenStartAlarm),
              ),
            ),
          );
          await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
          expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
        },
      );

      testWidgets('End alarm does not show play speech button',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: alarmNavigator,
              child: AlarmPage(alarm: endAlarmWithNoSpeech),
            ),
          ),
        );
        await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
        expect(find.byType(PlayAlarmSpeechButton), findsNothing);
      });

      testWidgets('End alarm shows play button when speech is present',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(PopAwareAlarmPage(
            alarm: startAlarm,
            alarmNavigator: alarmNavigator,
            child: AlarmPage(alarm: endAlarmWithSpeech),
          )),
        );
        await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
        expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
      });
    });

    group('automatic playes', () {
      final payload = StartAlarm(ActivityDay(activityWithStartSpeech, day));

      testWidgets('speech plays when notification is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: alarmNavigator,
              child: AlarmPage(alarm: startAlarm),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.playSound), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.stop), findsNothing);
        selectNotificationSubject.add(payload);
        await tester.pumpAndSettle();
        expect(find.byIcon(AbiliaIcons.playSound), findsNothing);
        expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
        await tester.pump(AlarmSpeechCubit.minSpeechDelay);
      }, skip: Config.isMP);

      testWidgets('speech plays when notification screen is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: alarmNavigator,
              child: AlarmPage(alarm: startAlarm),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.playSound), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.stop), findsNothing);
        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();
        expect(find.byIcon(AbiliaIcons.playSound), findsNothing);
        expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
        await tester.pump(AlarmSpeechCubit.minSpeechDelay);
      });

      testWidgets('speech plays after time delay is up',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: alarmNavigator,
              child: AlarmPage(
                alarm: startAlarm,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.playSound), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.stop), findsNothing);
        // wait untill alarm is over
        await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
        // should play alarm
        expect(find.byIcon(AbiliaIcons.playSound), findsNothing);
        expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
      });

      testWidgets('speech plays after time delay is up 5 min alarm',
          (WidgetTester tester) async {
        const fiveMin = Duration(minutes: 5);
        when(() => mockMPSettingsBloc.state).thenReturn(
            MemoplannerSettingsLoaded(MemoplannerSettings(
                alarm: AlarmSettings(durationMs: fiveMin.inMilliseconds))));
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: alarmNavigator,
              child: AlarmPage(alarm: startAlarm),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.playSound), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.stop), findsNothing);
        // Wait min speech
        await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
        // not playing
        expect(find.byIcon(AbiliaIcons.playSound), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.stop), findsNothing);
        // wait alarm time
        await tester.pumpAndSettle(fiveMin - AlarmSpeechCubit.minSpeechDelay);
        // Should play
        expect(find.byIcon(AbiliaIcons.playSound), findsNothing);
        expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
      });

      testWidgets('speech plays does not play before after time delay is up',
          (WidgetTester tester) async {
        when(() => mockMPSettingsBloc.state)
            .thenReturn(const MemoplannerSettingsNotLoaded());
        await tester.pumpWidget(
          wrapWithMaterialApp(
            PopAwareAlarmPage(
              alarm: startAlarm,
              alarmNavigator: alarmNavigator,
              child: AlarmPage(
                alarm: startAlarm,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.playSound), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.stop), findsNothing);
        // wait Default time
        final defaultDuration = const AlarmSettings().duration;
        await tester.pumpAndSettle(defaultDuration);
        // not playing
        expect(find.byIcon(AbiliaIcons.playSound), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.stop), findsNothing);
        GetIt.I<Ticker>()
            .setFakeTime(startTime.add(defaultDuration), setTicker: false);
        mockMPSettingsBlocStream.add(const MemoplannerSettingsLoaded(
            MemoplannerSettings(alarm: AlarmSettings(durationMs: 0))));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        // Should play
        expect(find.byIcon(AbiliaIcons.playSound), findsNothing);
        expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
      });
    });
  });

  testWidgets('Clock is visible', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithMaterialApp(PopAwareAlarmPage(
        alarm: startAlarm,
        alarmNavigator: alarmNavigator,
        child: AlarmPage(alarm: endAlarmWithNoSpeech),
      )),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AbiliaClock), findsOneWidget);
  });

  testWidgets(
      'BUG SGC-1553 - '
      'checking all items off checklist in checkable activity '
      'shows CheckActivityConfirmDialog and confirming that '
      'cancels alarms', (WidgetTester tester) async {
    final checklist = Checklist(
      questions: const [
        Question(id: 1, name: '1one'),
      ],
    );
    final checkableWithChecklist = Activity.createNew(
      title: 'Checkable',
      startTime: startTime,
      checkable: true,
      infoItem: checklist,
    );

    final StartAlarm startAlarm = StartAlarm(
      ActivityDay(checkableWithChecklist, day),
    );
    await tester.pumpWidget(
      wrapWithMaterialApp(
        PopAwareAlarmPage(
          alarm: startAlarm,
          alarmNavigator: alarmNavigator,
          child: AlarmPage(alarm: startAlarm),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var q in checklist.questions) {
      await tester.tap(find.text(q.name));
      await tester.pumpAndSettle();
    }
    expect(find.byType(CheckActivityConfirmDialog), findsOneWidget);
    await tester.tap(find.byType(YesButton));
    await tester.pumpAndSettle();

    expect(
      localNotificationLog.where((call) => call.method == 'cancel'),
      hasLength(
        greaterThanOrEqualTo(unsignedOffActivityReminders.length + 1),
      ),
    );
  });

  group('When checkable activity shows check button', () {
    testWidgets('on Start alarm when activity has no end time',
        (WidgetTester tester) async {
      final alarm = StartAlarm(
        ActivityDay(
          Activity.createNew(startTime: startTime, checkable: true),
          day,
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: alarm,
            alarmNavigator: alarmNavigator,
            child: AlarmPage(alarm: alarm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
    });

    testWidgets('NOT on Start alarm when activity has end time',
        (WidgetTester tester) async {
      final alarm = StartAlarm(
        ActivityDay(
          Activity.createNew(
            startTime: startTime,
            duration: 5.minutes(),
            checkable: true,
          ),
          day,
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: alarm,
            alarmNavigator: alarmNavigator,
            child: AlarmPage(alarm: alarm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.activityCheckButton), findsNothing);
    });

    testWidgets('on End alarm', (WidgetTester tester) async {
      final alarm = EndAlarm(
        ActivityDay(
          Activity.createNew(
            startTime: startTime,
            duration: 5.minutes(),
            checkable: true,
          ),
          day,
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: alarm,
            alarmNavigator: alarmNavigator,
            child: AlarmPage(alarm: alarm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
    });

    testWidgets(
        'on Start alarm when activity has '
        'end time but alarm only at start', (WidgetTester tester) async {
      final alarm = StartAlarm(
        ActivityDay(
          Activity.createNew(
            startTime: startTime,
            duration: 5.minutes(),
            checkable: true,
            alarmType:
                const Alarm(type: AlarmType.silent, onlyStart: true).intValue,
          ),
          day,
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: alarm,
            alarmNavigator: alarmNavigator,
            child: AlarmPage(alarm: alarm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
    });

    testWidgets('NOT when that day is signed off', (WidgetTester tester) async {
      final alarm = StartAlarm(
        ActivityDay(
          Activity.createNew(
            startTime: startTime,
            checkable: true,
          ).signOff(day),
          day,
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: alarm,
            alarmNavigator: alarmNavigator,
            child: AlarmPage(alarm: alarm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.activityCheckButton), findsNothing);
    });

    testWidgets('NOT on reminders before', (WidgetTester tester) async {
      final time = 5.minutes();
      final reminder = ReminderBefore(
        ActivityDay(
          Activity.createNew(
            startTime: startTime,
            checkable: true,
            reminderBefore: [time.inMilliseconds],
          ),
          day,
        ),
        reminder: time,
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: reminder,
            alarmNavigator: alarmNavigator,
            child: ReminderPage(reminder: reminder),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.activityCheckButton), findsNothing);
    });

    testWidgets('on unchecked reminders', (WidgetTester tester) async {
      final time = 15.minutes();
      final reminder = ReminderUnchecked(
        ActivityDay(
          Activity.createNew(
            startTime: startTime,
            checkable: true,
            reminderBefore: [time.inMilliseconds],
          ),
          day,
        ),
        reminder: time,
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: reminder,
            alarmNavigator: alarmNavigator,
            child: ReminderPage(reminder: reminder),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
    });
  });
}
