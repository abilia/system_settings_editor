import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../fakes/all.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SoundBloc soundBloc;

  final dummyFile =
      UnstoredAbiliaFile.forTest('testfile', 'jksd', File('nbnb'));

  setUp(() {
    const MethodChannel('xyz.luan/audioplayers')
        .setMockMethodCallHandler((methodCall) {
      return null;
    });

    soundBloc = SoundBloc(
      storage: FakeFileStorage(),
      userFileBloc: FakeUserFileBloc(),
    );
  });

  group('SoundBloc', () {
    blocTest(
      'Initial state is NoSoundPlaying',
      build: () => soundBloc,
      verify: (SoundBloc bloc) => expect(
        bloc.state,
        const NoSoundPlaying(),
      ),
    );
  });

  group('SoundEvent', () {
    test('PlaySound emits SoundPlaying', () {
      soundBloc.add(PlaySound(dummyFile));
      expectLater(
        soundBloc.stream,
        emitsInOrder([
          SoundPlaying(dummyFile),
        ]),
      );
    });

    test('StopSound emits NoSoundPlaying', () async {
      soundBloc.add(PlaySound(dummyFile));
      expect(await soundBloc.stream.first, SoundPlaying(dummyFile));
      soundBloc.add(const StopSound());
      expect(await soundBloc.stream.first, const NoSoundPlaying());
    });

    test('SoundCompleted emits NoSoundPlaying', () async {
      soundBloc.add(PlaySound(dummyFile));
      expect(await soundBloc.stream.first, SoundPlaying(dummyFile));
      soundBloc.add(const SoundCompleted());
      expect(await soundBloc.stream.first, const NoSoundPlaying());
    });

    test('ResetPlayer resets the AudioPlayer', () async {
      final initialAudioPlayer = soundBloc.audioPlayer;
      soundBloc.add(const ResetPlayer());
      await Future.delayed(10.milliseconds());
      expect(
        soundBloc.audioPlayer == initialAudioPlayer,
        isFalse,
      );
    });

    const duration = 10000;
    final position = 5.seconds();
    test('PositionChanged emits SoundPlaying', () async {
      soundBloc.add(PlaySound(dummyFile));
      expect(await soundBloc.stream.first, SoundPlaying(dummyFile));
      soundBloc.add(
        PositionChanged(
          dummyFile,
          duration,
          position,
        ),
      );
      expect(
        await soundBloc.stream.first,
        SoundPlaying(
          dummyFile,
          duration: duration,
          position: position,
        ),
      );
    });

    test(
        'When PlaySound and StopSound is added within 250 ms of each other only the first event triggers',
        () async {
      soundBloc
        ..add(PlaySound(dummyFile))
        ..add(const StopSound());
      await Future.delayed(10.milliseconds());
      expect(soundBloc.state, SoundPlaying(dummyFile));
    });

    test(
        'When PlaySound and StopSound is added with more than 250 ms of each other both event triggers',
        () async {
      soundBloc.add(PlaySound(dummyFile));
      await Future.delayed(SoundBloc.spamProtectionDelay);
      soundBloc.add(const StopSound());
      await Future.delayed(10.milliseconds());
      expect(soundBloc.state, const NoSoundPlaying());
    });
  });
}
