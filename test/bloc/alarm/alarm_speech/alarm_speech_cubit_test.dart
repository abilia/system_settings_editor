import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockUserFileBloc mockUserFileBloc;
  group('AlarmSpeechCubit', () {
    final startTime = DateTime(2021, 10, 15, 09, 29);
    final day = DateTime(2021, 10, 15);
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

    final activity = Activity.createNew(
      title: 'title',
      startTime: startTime,
      extras: Extras.createNew(
        startTimeExtraAlarm: speechFile,
      ),
    );
    final activityNoSound = Activity.createNew(
      title: 'title',
      startTime: startTime,
      extras: Extras.createNew(
        startTimeExtraAlarm: speechFile,
      ),
      alarmType: noAlarm,
    );

    final startAlarm = StartAlarm(activity, day);
    final startAlarmNoSound = StartAlarm(activityNoSound, day);
    const MethodChannel localNotificationChannel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    const MethodChannel audioPlayerChannel =
        MethodChannel('xyz.luan/audioplayers');
    final List<MethodCall> localNotificationLog = <MethodCall>[];
    final List<MethodCall> audioLog = <MethodCall>[];

    List<ActiveNotification> activeNotifications = [];

    setUpAll(() {
      registerFallbackValues();
    });

    setUp(() async {
      localNotificationLog.clear();
      localNotificationChannel.setMockMethodCallHandler((methodCall) async {
        localNotificationLog.add(methodCall);
        if (methodCall.method == 'getActiveNotifications') {
          return activeNotifications
              .map((a) => {
                    'id': a.id,
                    'channelId': a.channelId,
                    'title': a.title,
                    'body': a.body,
                  })
              .toList();
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
      when(() => mockUserFileBloc.state)
          .thenReturn(const UserFilesLoaded([userFile]));
    });

    tearDown(() {
      activeNotifications = [];
      clearNotificationSubject();
    });

    blocTest(
      'emits nothing [] when nothing is added',
      build: () => AlarmSpeechCubit(
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        selectedNotificationStream: selectNotificationSubject,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
        ),
      ),
      expect: () => [],
      verify: (_) => () => expect(audioLog, isEmpty),
    );

    blocTest(
      'emits AlarmPlayed when Alarm is No Alarm',
      build: () => AlarmSpeechCubit(
        alarm: startAlarmNoSound,
        alarmSettings: const AlarmSettings(),
        selectedNotificationStream: selectNotificationSubject,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
        ),
      ),
      expect: () => [const AlarmSpeechPlayed()],
      verify: (_) => () {
        expect(audioLog, hasLength(1));
        expect(audioLog.single.method, 'play');
      },
    );

    blocTest(
      'emits if active notification and alarm time goes out ',
      setUp: () => activeNotifications = [
        ActiveNotification(
          startAlarm.hashCode,
          'channelId',
          'title',
          'body',
        ),
      ],
      build: () => AlarmSpeechCubit(
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(durationMs: 0),
        selectedNotificationStream: selectNotificationSubject..add(startAlarm),
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
        ),
      ),
      wait: AlarmSpeechCubit.minSpeechDelay,
      expect: () => [const AlarmSpeechPlayed()],
      verify: (_) => () {
        expect(audioLog, hasLength(1));
        expect(audioLog.single.method, 'play');
      },
    );

    blocTest(
      'emits nothing if active notification',
      setUp: () => activeNotifications = [
        ActiveNotification(
          startAlarm.hashCode,
          'channelId',
          'title',
          'body',
        ),
      ],
      build: () => AlarmSpeechCubit(
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        selectedNotificationStream: selectNotificationSubject..add(startAlarm),
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
        ),
      ),
      expect: () => [],
      verify: (_) => () => expect(audioLog, isEmpty),
    );

    blocTest(
      'emits AlarmPlayed after time is up',
      build: () => AlarmSpeechCubit(
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(durationMs: 0),
        selectedNotificationStream: selectNotificationSubject,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
        ),
      ),
      wait: AlarmSpeechCubit.minSpeechDelay,
      expect: () => [const AlarmSpeechPlayed()],
      verify: (_) => () {
        expect(audioLog, hasLength(1));
        expect(audioLog.single.method, 'play');
      },
    );

    blocTest(
      'emits AlarmPlayed when notification tapped',
      build: () => AlarmSpeechCubit(
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        selectedNotificationStream: selectNotificationSubject..add(startAlarm),
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
        ),
      ),
      expect: () => [const AlarmSpeechPlayed()],
      verify: (_) => () {
        expect(audioLog, hasLength(1));
        expect(audioLog.single.method, 'play');
      },
    );
    blocTest(
      'emits AlarmPlayed bloc played',
      build: () => AlarmSpeechCubit(
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        selectedNotificationStream: selectNotificationSubject,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
        )..play(speechFile),
      ),
      expect: () => [const AlarmSpeechPlayed()],
    );
  });
}
