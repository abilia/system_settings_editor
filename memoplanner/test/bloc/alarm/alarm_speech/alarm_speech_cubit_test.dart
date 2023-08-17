import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
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
    List<ActiveNotification> activeNotifications = [];
    late MockUserFileBloc mockUserFileBloc;
    late MockAudioPlayer mockAudioPlayer;
    late StreamController<Touch> touchStream;

    setUpAll(() {
      registerFallbackValues();
    });

    setUp(() async {
      touchStream = StreamController<Touch>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(localNotificationChannel,
              (methodCall) async {
        if (methodCall.method == 'initialize') return Future.value(true);
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
        return null;
      });
      mockAudioPlayer = mockAudioPlayerFactory();
      mockUserFileBloc = MockUserFileBloc();
      when(() => mockUserFileBloc.state)
          .thenReturn(const UserFilesLoaded([userFile]));
    });

    tearDown(() {
      touchStream.close();
      activeNotifications = [];
      clearNotificationSubject();
    });

    blocTest('emits nothing when nothing is added',
        build: () => AlarmSpeechCubit(
              now: () => startTime,
              alarm: startAlarm,
              alarmSettings: const AlarmSettings(),
              touchStream: touchStream.stream,
              soundBloc: SoundBloc(
                audioPlayer: mockAudioPlayer,
                storage: FakeFileStorage(),
                userFileBloc: mockUserFileBloc,
                spamProtectionDelay: Duration.zero,
              ),
              remoteMessageStream: FakePushCubit().stream,
            ),
        expect: () => [],
        verify: (_) => () => verifyNever(() => mockAudioPlayer.play(any())));

    blocTest(
      'emits AlarmPlayed when Alarm is No Alarm',
      build: () => AlarmSpeechCubit(
        now: () => startTime,
        alarm: startAlarmNoSound,
        alarmSettings: const AlarmSettings(),
        touchStream: touchStream.stream,
        soundBloc: SoundBloc(
          audioPlayer: mockAudioPlayer,
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
          spamProtectionDelay: Duration.zero,
        ),
        remoteMessageStream: FakePushCubit().stream,
      ),
      expect: () => [AlarmSpeechState.played],
      verify: (_) => verify(() => mockAudioPlayer.play(any())),
    );

    blocTest(
      'emits if active notification and alarm time goes out ',
      setUp: () => activeNotifications = [
        ActiveNotification(
          id: startAlarm.hashCode,
          groupKey: 'channelId',
          title: 'title',
          body: 'body',
        ),
      ],
      build: () => AlarmSpeechCubit(
        now: () => startTime,
        alarm: startAlarm,
        alarmSettings: const AlarmSettings(durationMs: 0),
        touchStream: touchStream.stream,
        selectedNotificationStream: selectNotificationSubject..add(startAlarm),
        soundBloc: SoundBloc(
          audioPlayer: mockAudioPlayer,
          storage: FakeFileStorage(),
          userFileBloc: mockUserFileBloc,
          spamProtectionDelay: Duration.zero,
        ),
        remoteMessageStream: FakePushCubit().stream,
      ),
      wait: AlarmSpeechCubit.minSpeechDelay,
      expect: () => [AlarmSpeechState.played],
      verify: (_) => verify(() => mockAudioPlayer.play(any())),
    );

    blocTest('emits nothing if active notification',
        setUp: () => activeNotifications = [
              ActiveNotification(
                id: startAlarm.hashCode,
                groupKey: 'channelId',
                title: 'title',
                body: 'body',
              ),
            ],
        build: () => AlarmSpeechCubit(
              now: () => startTime,
              alarm: startAlarm,
              alarmSettings: const AlarmSettings(),
              touchStream: touchStream.stream,
              selectedNotificationStream: selectNotificationSubject
                ..add(startAlarm),
              soundBloc: SoundBloc(
                audioPlayer: mockAudioPlayer,
                storage: FakeFileStorage(),
                userFileBloc: mockUserFileBloc,
                spamProtectionDelay: Duration.zero,
              ),
              remoteMessageStream: FakePushCubit().stream,
            ),
        expect: () => [],
        verify: (_) => () => verifyNever(() => mockAudioPlayer.play(any())));

    blocTest('emits AlarmPlayed after time is up',
        build: () => AlarmSpeechCubit(
              now: () => startTime,
              alarm: startAlarm,
              alarmSettings: const AlarmSettings(durationMs: 0),
              touchStream: touchStream.stream,
              soundBloc: SoundBloc(
                audioPlayer: mockAudioPlayer,
                storage: FakeFileStorage(),
                userFileBloc: mockUserFileBloc,
                spamProtectionDelay: Duration.zero,
              ),
              remoteMessageStream: FakePushCubit().stream,
            ),
        wait: AlarmSpeechCubit.minSpeechDelay,
        expect: () => [AlarmSpeechState.played],
        verify: (_) => () => verifyNever(() => mockAudioPlayer.play(any())));

    blocTest('Late started bloc emits after shorter time',
        build: () => AlarmSpeechCubit(
              now: () => startTime.add(1.seconds()),
              alarm: startAlarm,
              alarmSettings: const AlarmSettings(durationMs: 0),
              touchStream: touchStream.stream,
              soundBloc: SoundBloc(
                audioPlayer: mockAudioPlayer,
                storage: FakeFileStorage(),
                userFileBloc: mockUserFileBloc,
                spamProtectionDelay: Duration.zero,
              ),
              remoteMessageStream: FakePushCubit().stream,
            ),
        wait: AlarmSpeechCubit.minSpeechDelay - 1.seconds(),
        expect: () => [AlarmSpeechState.played],
        verify: (_) => () => verify(() => mockAudioPlayer.play(any())));

    blocTest('emits AlarmPlayed when screen is tapped',
        build: () => AlarmSpeechCubit(
              now: () => startTime,
              alarm: startAlarm,
              alarmSettings: const AlarmSettings(),
              touchStream: (touchStream..add(Touch.down)).stream,
              soundBloc: SoundBloc(
                audioPlayer: mockAudioPlayer,
                storage: FakeFileStorage(),
                userFileBloc: mockUserFileBloc,
                spamProtectionDelay: Duration.zero,
              ),
              remoteMessageStream: FakePushCubit().stream,
            ),
        expect: () => [AlarmSpeechState.played],
        verify: (_) => () => verify(() => mockAudioPlayer.play(any())));

    blocTest('emits AlarmPlayed when notification tapped',
        build: () => AlarmSpeechCubit(
              now: () => startTime,
              alarm: startAlarm,
              alarmSettings: const AlarmSettings(),
              touchStream: touchStream.stream,
              selectedNotificationStream: selectNotificationSubject
                ..add(startAlarm),
              soundBloc: SoundBloc(
                audioPlayer: mockAudioPlayer,
                storage: FakeFileStorage(),
                userFileBloc: mockUserFileBloc,
                spamProtectionDelay: Duration.zero,
              ),
              remoteMessageStream: FakePushCubit().stream,
            ),
        expect: () => [AlarmSpeechState.played],
        verify: (_) => () => verify(() => mockAudioPlayer.play(any())));

    blocTest('emits AlarmPlayed bloc played',
        build: () => AlarmSpeechCubit(
              now: () => startTime,
              alarm: startAlarm,
              alarmSettings: const AlarmSettings(),
              touchStream: touchStream.stream,
              soundBloc: SoundBloc(
                audioPlayer: mockAudioPlayer,
                storage: FakeFileStorage(),
                userFileBloc: mockUserFileBloc,
                spamProtectionDelay: Duration.zero,
              )..add(PlaySound(speechFile)),
              remoteMessageStream: FakePushCubit().stream,
            ),
        expect: () => [AlarmSpeechState.played],
        verify: (_) => () => verify(() => mockAudioPlayer.play(any())));
  });
}
