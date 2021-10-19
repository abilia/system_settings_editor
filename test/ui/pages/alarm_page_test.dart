import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);
  final day = startTime.onlyDays();
  final userFile = UserFile(
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

  final activity = Activity.createNew(
    title: 'title',
    startTime: startTime,
    extras: Extras.createNew(
      startTimeExtraAlarm: speechFile,
    ),
  );

  final StartAlarm startAlarm = StartAlarm(activity, day);
  final EndAlarm endAlarm = EndAlarm(activity, day);
  AlarmNavigator _alarmNavigator = AlarmNavigator();
  late MockMemoplannerSettingBloc mockMPSettingsBloc;
  late MockUserFileBloc mockUserFileBloc;

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ActivitiesBloc>(
              create: (context) => FakeActivitiesBloc(),
            ),
            BlocProvider<ClockBloc>(
              create: (context) => ClockBloc(
                  StreamController<DateTime>().stream,
                  initialTime: day),
            ),
            BlocProvider<SettingsBloc>(
              create: (context) => SettingsBloc(
                settingsDb: FakeSettingsDb(),
              ),
            ),
            BlocProvider<MemoplannerSettingBloc>(
              create: (context) => mockMPSettingsBloc,
            ),
            BlocProvider<UserFileBloc>(
              create: (context) => mockUserFileBloc,
            ),
          ],
          child: widget,
        ),
      );

  setUpAll(() {
    registerFallbackValue(MemoplannerSettingsNotLoaded());
    registerFallbackValue(UpdateMemoplannerSettings(MapView({})));
    registerFallbackValue(UserFilesNotLoaded());
    registerFallbackValue(LoadUserFiles());
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

    mockUserFileBloc = MockUserFileBloc();
    when(() => mockUserFileBloc.stream).thenAnswer((_) => Stream.empty());
    mockUserFileBloc = MockUserFileBloc();
    when(() => mockUserFileBloc.state).thenReturn(UserFilesLoaded([userFile]));
    mockMPSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMPSettingsBloc.state).thenReturn(MemoplannerSettingsLoaded(
        MemoplannerSettings(alarm: AlarmSettings(durationMs: 0))));
    await initializeDateFormatting();
    GetItInitializer()
      ..fileStorage = FakeFileStorage()
      ..database = FakeDatabase()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
    clearNotificationSubject();
  });

  group('alarm speech button tests', () {
    testWidgets('Alarm page visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: startAlarm,
            alarmNavigator: _alarmNavigator,
            child: AlarmPage(alarm: startAlarm),
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
            alarmNavigator: _alarmNavigator,
            child: AlarmPage(alarm: startAlarm),
          ),
        ),
      );
      await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
      expect(find.byType(PlaySpeechButton), findsOneWidget);
    });

    testWidgets('End alarm does not show play speech button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: startAlarm,
            alarmNavigator: _alarmNavigator,
            child: AlarmPage(alarm: endAlarm),
          ),
        ),
      );
      await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
      expect(find.byType(PlaySpeechButton), findsNothing);
    });
  });
  group('alarm speech automatic playes', () {
    final payload = StartAlarm(activity, day);

    testWidgets('speech plays when notification is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: startAlarm,
            alarmNavigator: _alarmNavigator,
            child: AlarmPage(alarm: startAlarm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlaySpeechButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.play_sound), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.stop), findsNothing);
      selectNotificationSubject.add(payload);
      await tester.pumpAndSettle();
      expect(find.byIcon(AbiliaIcons.play_sound), findsNothing);
      expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
      await tester.pump(AlarmSpeechCubit.minSpeechDelay);
    });

    testWidgets('speech plays after time delay is up',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: startAlarm,
            alarmNavigator: _alarmNavigator,
            child: AlarmPage(alarm: startAlarm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlaySpeechButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.play_sound), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.stop), findsNothing);
      // wait untill alarm is over
      await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
      // should play alarm
      expect(find.byIcon(AbiliaIcons.play_sound), findsNothing);
      expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
    });

    testWidgets('speech plays after time delay is up 5 min alarm',
        (WidgetTester tester) async {
      final fiveMin = Duration(minutes: 5);
      when(() => mockMPSettingsBloc.state).thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(
              alarm: AlarmSettings(durationMs: fiveMin.inMilliseconds))));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          PopAwareAlarmPage(
            alarm: startAlarm,
            alarmNavigator: _alarmNavigator,
            child: AlarmPage(alarm: startAlarm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PlaySpeechButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.play_sound), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.stop), findsNothing);
      // Wait min speech
      await tester.pumpAndSettle(AlarmSpeechCubit.minSpeechDelay);
      // not playing
      expect(find.byIcon(AbiliaIcons.play_sound), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.stop), findsNothing);
      // wait alarm time
      await tester.pumpAndSettle(fiveMin - AlarmSpeechCubit.minSpeechDelay);
      // Should play
      expect(find.byIcon(AbiliaIcons.play_sound), findsNothing);
      expect(find.byIcon(AbiliaIcons.stop), findsOneWidget);
    });
  });
}
