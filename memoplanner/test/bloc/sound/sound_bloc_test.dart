import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SoundBloc soundBloc;

  const Duration spamProtectionDelay = Duration(milliseconds: 100);
  late MockAudioPlayer mockAudioPlayer;

  final dummyFile =
      UnstoredAbiliaFile.forTest('testfile', 'jksd', File('nbnb'));
  setUpAll(registerFallbackValues);

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers'),
            (methodCall) async {
      return null;
    });
    mockAudioPlayer = mockAudioPlayerFactory();
    soundBloc = SoundBloc(
      audioPlayer: mockAudioPlayer,
      storage: FakeFileStorage(),
      userFileBloc: FakeUserFileBloc(),
      spamProtectionDelay: spamProtectionDelay,
    );
  });

  group('SoundBloc', () {
    blocTest(
      'Initial state is NoSoundPlaying',
      build: () => soundBloc,
      expect: () => [],
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
        'When PlaySound and StopSound is added within spamProtectionDelay only the first event triggers',
        () async {
      soundBloc
        ..add(PlaySound(dummyFile))
        ..add(const StopSound());
      await Future.delayed(10.milliseconds());
      expect(soundBloc.state, SoundPlaying(dummyFile));
    });

    test(
        'When PlaySound and StopSound is added with more than spamProtectionDelay both event triggers',
        () async {
      soundBloc.add(PlaySound(dummyFile));
      await Future.delayed(spamProtectionDelay);
      await Future.delayed(spamProtectionDelay);
      soundBloc.add(const StopSound());
      await Future.delayed(10.milliseconds());
      expect(soundBloc.state, const NoSoundPlaying());
    });
  });
}
