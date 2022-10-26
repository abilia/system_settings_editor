import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

    final startAlarm = StartAlarm(ActivityDay(activity, day));
    final startAlarmNoSound = StartAlarm(ActivityDay(activityNoSound, day));
    const MethodChannel localNotificationChannel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    const MethodChannel audioPlayerChannel =
        MethodChannel('xyz.luan/audioplayers');
    final List<MethodCall> localNotificationLog = <MethodCall>[];
    final List<MethodCall> audioLog = <MethodCall>[];
    List<ActiveNotification> activeNotifications = [];
    late MockUserFileCubit mockUserFileCubit;
    late StreamController<Touch> touchStream;

    setUpAll(() {
      registerFallbackValues();
    });

    setUp(() async {
      touchStream = StreamController<Touch>();
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
      mockUserFileCubit = MockUserFileCubit();
      when(() => mockUserFileCubit.state)
          .thenReturn(const UserFilesLoaded([userFile]));
    });

    tearDown(() {
      touchStream.close();
      activeNotifications = [];
      clearNotificationSubject();
    });

    blocTest(
      'emits nothing when nothing is added',
      build: () => AlarmSpeechCubit(
        now: () => startTime,
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        touchStream: touchStream.stream,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        ),
      ),
      expect: () => [],
      verify: (_) => () => expect(audioLog, isEmpty),
    );

    blocTest(
      'emits AlarmPlayed when Alarm is No Alarm',
      build: () => AlarmSpeechCubit(
        now: () => startTime,
        alarm: startAlarmNoSound,
        alarmSettings: const AlarmSettings(),
        touchStream: touchStream.stream,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        ),
      ),
      expect: () => [AlarmSpeechState.played],
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
        now: () => startTime,
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(durationMs: 0),
        touchStream: touchStream.stream,
        selectedNotificationStream: selectNotificationSubject..add(startAlarm),
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        ),
      ),
      wait: AlarmSpeechCubit.minSpeechDelay,
      expect: () => [AlarmSpeechState.played],
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
        now: () => startTime,
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        touchStream: touchStream.stream,
        selectedNotificationStream: selectNotificationSubject..add(startAlarm),
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        ),
      ),
      expect: () => [],
      verify: (_) => () => expect(audioLog, isEmpty),
    );

    blocTest(
      'emits AlarmPlayed after time is up',
      build: () => AlarmSpeechCubit(
        now: () => startTime,
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(durationMs: 0),
        touchStream: touchStream.stream,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        ),
      ),
      wait: AlarmSpeechCubit.minSpeechDelay,
      expect: () => [AlarmSpeechState.played],
      verify: (_) => () {
        expect(audioLog, hasLength(1));
        expect(audioLog.single.method, 'play');
      },
    );

    blocTest(
      'Late started bloc emits after shorter time',
      build: () => AlarmSpeechCubit(
        now: () => startTime.add(1.seconds()),
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(durationMs: 0),
        touchStream: touchStream.stream,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        ),
      ),
      wait: AlarmSpeechCubit.minSpeechDelay - 1.seconds(),
      expect: () => [AlarmSpeechState.played],
      verify: (_) => () {
        expect(audioLog, hasLength(1));
        expect(audioLog.single.method, 'play');
      },
    );

    blocTest(
      'emits AlarmPlayed when screen is tapped',
      build: () => AlarmSpeechCubit(
        now: () => startTime,
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        touchStream: (touchStream..add(Touch.down)).stream,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        ),
      ),
      expect: () => [AlarmSpeechState.played],
      verify: (_) => () {
        expect(audioLog, hasLength(1));
        expect(audioLog.single.method, 'play');
      },
    );

    blocTest(
      'emits AlarmPlayed when notification tapped',
      build: () => AlarmSpeechCubit(
        now: () => startTime,
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        touchStream: touchStream.stream,
        selectedNotificationStream: selectNotificationSubject..add(startAlarm),
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        ),
      ),
      expect: () => [AlarmSpeechState.played],
      verify: (_) => () {
        expect(audioLog, hasLength(1));
        expect(audioLog.single.method, 'play');
      },
    );

    blocTest(
      'emits AlarmPlayed bloc played',
      build: () => AlarmSpeechCubit(
        now: () => startTime,
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(),
        touchStream: touchStream.stream,
        soundCubit: SoundCubit(
          storage: FakeFileStorage(),
          userFileCubit: mockUserFileCubit,
        )..play(speechFile),
      ),
      expect: () => [AlarmSpeechState.played],
    );
  });
}
