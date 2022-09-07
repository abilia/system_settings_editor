import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';

const jsonTestString1 =
    '''{"startTimeExtraAlarm":"/handi/user/voicenotes/voice_recording_30ee75a1-6c2f-4fcd-9f06-d2365e6012b0.wav","startTimeExtraAlarmFileId":"30ee75a1-6c2f-4fcd-9f06-d2365e6012b0","endTimeExtraAlarm":"higjhvvh","endTimeExtraAlarmFileId":"734871297863"}''';

void main() {
  test('test creating extras object', () {
    const jsonString =
        '''{"startTimeExtraAlarm":"abcdef","startTimeExtraAlarmFileId":"ghijkl","endTimeExtraAlarm":"mnopqrs","endTimeExtraAlarmFileId":"tuvwxyz"}''';

    final extras = Extras.createNew(
      startTimeExtraAlarm: AbiliaFile.from(
        id: 'ghijkl',
        path: 'abcdef',
      ),
      endTimeExtraAlarm: AbiliaFile.from(
        id: 'tuvwxyz',
        path: 'mnopqrs',
      ),
    );

    expect(extras.startTimeExtraAlarm.path, 'abcdef');
    expect(extras.startTimeExtraAlarm.id, 'ghijkl');
    expect(extras.endTimeExtraAlarm.path, 'mnopqrs');
    expect(extras.endTimeExtraAlarm.id, 'tuvwxyz');
    expect(extras.toJsonString(), jsonString);
  });

  test('test json parsing', () {
    final extras = Extras.fromJsonString(jsonTestString1);

    expect(extras.startTimeExtraAlarm.path,
        '/handi/user/voicenotes/voice_recording_30ee75a1-6c2f-4fcd-9f06-d2365e6012b0.wav');
    expect(
        extras.startTimeExtraAlarm.id, '30ee75a1-6c2f-4fcd-9f06-d2365e6012b0');
    expect(extras.endTimeExtraAlarm.path, 'higjhvvh');
    expect(extras.endTimeExtraAlarm.id, '734871297863');
    expect(extras.toJsonString(), jsonTestString1);
  });

  test('test changing value', () {
    const modifiendJsonString =
        '''{"startTimeExtraAlarm":"new startTimeExtraAlarm","endTimeExtraAlarm":"higjhvvh","endTimeExtraAlarmFileId":"734871297863"}''';

    final extras = Extras.fromJsonString(jsonTestString1);

    final extrasChanged = extras.copyWith(
        startTimeExtraAlarm: AbiliaFile.from(path: 'new startTimeExtraAlarm'));
    expect(extrasChanged.startTimeExtraAlarm,
        AbiliaFile.from(path: 'new startTimeExtraAlarm'));
    expect(extrasChanged.toJsonString(), modifiendJsonString);
  });

  test('test removing value', () {
    const modifiendJsonString =
        '''{"endTimeExtraAlarm":"higjhvvh","endTimeExtraAlarmFileId":"734871297863"}''';

    final extras = Extras.fromJsonString(jsonTestString1);

    final extrasChanged =
        extras.copyWith(startTimeExtraAlarm: AbiliaFile.empty);
    expect(extrasChanged.startTimeExtraAlarm.id, '');
    expect(extrasChanged.startTimeExtraAlarm.path, '');
    expect(extrasChanged.startTimeExtraAlarm.isEmpty, isTrue);
    expect(extrasChanged.toJsonString(), modifiendJsonString);
  });

  test('test from Extras.empty', () {
    const jsonString =
        '''{"startTimeExtraAlarm":"abcdef","startTimeExtraAlarmFileId":"ghijkl","endTimeExtraAlarm":"mnopqrs","endTimeExtraAlarmFileId":"tuvwxyz"}''';

    const extras = Extras.empty;

    final extrasChanged = extras.copyWith(
        startTimeExtraAlarm: AbiliaFile.from(
          path: 'abcdef',
          id: 'ghijkl',
        ),
        endTimeExtraAlarm: AbiliaFile.from(
          path: 'mnopqrs',
          id: 'tuvwxyz',
        ));

    expect(extrasChanged.startTimeExtraAlarm.path, 'abcdef');
    expect(extrasChanged.startTimeExtraAlarm.id, 'ghijkl');
    expect(extrasChanged.endTimeExtraAlarm.path, 'mnopqrs');
    expect(extrasChanged.endTimeExtraAlarm.id, 'tuvwxyz');
    expect(extrasChanged.toJsonString(), jsonString);
  });
}
