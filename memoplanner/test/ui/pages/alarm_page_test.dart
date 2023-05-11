import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_fakes/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';
import '../../mocks/mocks.dart';
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
  late StreamController<MemoplannerSettings> mockMPSettingsBlocStream;
  late StreamController<ActivitiesChanged> mockActivitiesBlocStream;
  late MockUserFileBloc mockUserFileBloc;
  late MockActivitiesBloc mockActivitiesBloc;
  late MockActivityRepository mockActivityRepository;
  late MockBaseClient mockClient;

  Widget wrapWithMaterialApp(Widget widget, {PushCubit? pushCubit}) =>
      MaterialApp(
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
                create: (context) => mockActivitiesBloc,
              ),
              BlocProvider<ClockBloc>(
                create: (context) => ClockBloc.fixed(day),
              ),
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
              ),
              BlocProvider<MemoplannerSettingsBloc>(
                create: (context) => mockMPSettingsBloc,
              ),
              BlocProvider<UserFileBloc>(
                create: (context) => mockUserFileBloc,
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
              BlocProvider<PushCubit>(
                create: (context) => pushCubit ?? FakePushCubit(),
              ),
              BlocProvider<NavigationCubit>(
                create: (_) => NavigationCubit(),
              ),
              BlocProvider<NightMode>(
                create: (context) => FakeNightMode(),
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
      if (methodCall.method == 'initialize') return Future.value(true);
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

    mockUserFileBloc = MockUserFileBloc();
    when(() => mockUserFileBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUserFileBloc.state)
        .thenReturn(const UserFilesLoaded([userFile]));
    mockMPSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMPSettingsBloc.state).thenReturn(MemoplannerSettingsLoaded(
        const MemoplannerSettings(alarm: AlarmSettings(durationMs: 0))));
    mockMPSettingsBlocStream = StreamController<MemoplannerSettings>();
    final settingsStream = mockMPSettingsBlocStream.stream.asBroadcastStream();
    when(() => mockMPSettingsBloc.stream).thenAnswer((_) => settingsStream);
    mockActivitiesBloc = MockActivitiesBloc();
    mockActivitiesBlocStream = StreamController<ActivitiesChanged>();
    final activitiesStream =
        mockActivitiesBlocStream.stream.asBroadcastStream();
    when(() => mockActivitiesBloc.stream).thenAnswer((_) => activitiesStream);
    when(() => mockActivitiesBloc.state).thenAnswer((_) => ActivitiesChanged());
    mockActivityRepository = MockActivityRepository();
    when(() => mockActivitiesBloc.activityRepository)
        .thenAnswer((_) => mockActivityRepository);
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([]));

    mockClient = MockBaseClient();
    when(() => mockClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((invocation) async => Response('body', 200));

    await initializeDateFormatting();
    GetItInitializer()
      ..fileStorage = FakeFileStorage()
      ..database = FakeDatabase()
      ..ticker = Ticker.fake(initialTime: startTime)
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..client = mockClient
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
    clearNotificationSubject();
    mockMPSettingsBlocStream.close();
    mockActivitiesBlocStream.close();
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
        // wait until alarm is over
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
        mockMPSettingsBlocStream.add(MemoplannerSettingsLoaded(
            const MemoplannerSettings(alarm: AlarmSettings(durationMs: 0))));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        // Should play
        expect(find.byIcon(AbiliaIcons.playSound), findsNothing);
        expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
      });

      group('Play speech after alarm ends from push', () {
        Future<void> testIncomingPush(
            WidgetTester tester, String pushKey) async {
          final pushCubit = PushCubit();
          await tester.pumpWidget(
            wrapWithMaterialApp(
              PopAwareAlarmPage(
                alarm: startAlarm,
                alarmNavigator: alarmNavigator,
                child: AlarmPage(
                  alarm: startAlarm,
                ),
              ),
              pushCubit: pushCubit,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(PlayAlarmSpeechButton), findsOneWidget);
          expect(find.byIcon(AbiliaIcons.playSound), findsOneWidget);
          expect(find.byIcon(AbiliaIcons.stop), findsNothing);

          // fake incoming push
          pushCubit.fakePush(
            data: {
              pushKey: '${startAlarm.hashCode}',
            },
          );

          await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
          // should play alarm
          expect(find.byIcon(AbiliaIcons.playSound), findsNothing);
          expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
        }

        testWidgets('speech plays after alarm ends from stop sound push',
            (WidgetTester tester) async {
          await testIncomingPush(tester, RemoteAlarm.stopSoundKey);
        });

        testWidgets('speech plays after alarm ends from pop alarm push',
            (WidgetTester tester) async {
          await testIncomingPush(tester, RemoteAlarm.popKey);
        });
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

  group('Stopping alarms', () {
    testWidgets(
        'touching page stops alarms '
        'and sends to backend to stop sound', (WidgetTester tester) async {
      final alarm = StartAlarm(
        ActivityDay(Activity.createNew(startTime: startTime), day),
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
      await tester.tapAt(tester.getCenter(find.byType(AlarmPage)));
      await tester.pumpAndSettle();

      expect(
        localNotificationLog
            .where((call) => call.method == 'cancel')
            .single
            .arguments,
        {'id': alarm.hashCode, 'tag': null},
      );
      final captured = verify(() => mockClient.post(any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'))).captured;

      expect(
        captured.single,
        '{"${RemoteAlarm.stopSoundKey}":"${alarm.hashCode}"}',
      );
    });

    testWidgets(
        'go back on alarm stops alarms '
        'and sends to backend to stop alarm sound and pop',
        (WidgetTester tester) async {
      final alarm = StartAlarm(
        ActivityDay(Activity.createNew(startTime: startTime), day),
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
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      expect(
        localNotificationLog
            .where((call) => call.method == 'cancel')
            .single
            .arguments,
        {'id': alarm.hashCode, 'tag': null},
      );
      final captured = verify(() => mockClient.post(any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'))).captured;

      expect(
        captured.single,
        '{'
        '"${RemoteAlarm.popKey}":"${alarm.stackId}",'
        '"${RemoteAlarm.stopSoundKey}":"${alarm.hashCode}"'
        '}',
      );
    });
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

    testWidgets(
        'BUG SGC-1886 - Checklist gets unchecked when checking on two devices',
        (WidgetTester tester) async {
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

      final checkedActivity = checkableWithChecklist.copyWith(
        title: 'Checkable checked',
        infoItem: checklist.copyWith(
          checked: {
            Checklist.dayKey(startTime): const {0}
          },
        ),
        signedOffDates: {whaleDateFormat(startTime)},
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

      mockActivitiesBlocStream.add(ActivitiesChanged());
      when(() => mockActivityRepository.getById(any()))
          .thenAnswer((_) => Future.value(checkedActivity));
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value([checkedActivity]));

      await tester.pumpAndSettle();

      expect(find.byType(GreenButton), findsNothing);
    });

    testWidgets('BUG SGC-2033 - Checklist not responsive on reminder',
        (WidgetTester tester) async {
      const q1 = Question(id: 1, name: '1one');

      final checklist = Checklist(
        questions: const [q1, Question(id: 2, name: '2one')],
      );

      final checkableWithChecklist = Activity.createNew(
        title: 'Checklist',
        startTime: startTime,
        infoItem: checklist,
        checkable: true,
      );

      final reminder = ReminderUnchecked(
        ActivityDay(checkableWithChecklist, day),
        reminder: const Duration(minutes: 15),
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
      final checklistBefore =
          tester.widget<ChecklistView>(find.byType(ChecklistView));
      expect(checklistBefore.checklist.isSignedOff(q1, day), isFalse);

      await tester.tap(find.text(q1.name));
      await tester.pumpAndSettle();
      final checklistAfter =
          tester.widget<ChecklistView>(find.byType(ChecklistView));

      expect(checklistAfter.checklist.isSignedOff(q1, day), isTrue);
    });

    testWidgets(
        'BUG SGC-2033 - Checklist not responsive on reminder'
        ' with "show ongoing activity" setting on',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(800, 1280);
      tester.binding.window.devicePixelRatioTestValue = 1;

      // resets the screen to its orinal size after the test end
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      const q1 = Question(id: 1, name: '1one');
      final checklist = Checklist(
        questions: const [q1, Question(id: 2, name: '2one')],
      );

      final checkableWithChecklist = Activity.createNew(
        title: 'Checklist',
        startTime: startTime,
        infoItem: checklist,
        checkable: true,
      );

      final startAlarm = StartAlarm(
        ActivityDay(checkableWithChecklist, day),
        fullScreenActivity: true,
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
      expect(find.byType(FullScreenActivityPage), findsOneWidget);

      final checklistBefore = tester.widget<ChecklistView>(
        find.byType(ChecklistView),
      );
      expect(checklistBefore.checklist.isSignedOff(q1, day), isFalse);

      await tester.tap(find.text(q1.name));
      await tester.pumpAndSettle();
      final checklistAfter = tester.widget<ChecklistView>(
        find.byType(ChecklistView),
      );

      expect(checklistAfter.checklist.isSignedOff(q1, day), isTrue);
    }, skip: !Config.isMP);
  });
}
