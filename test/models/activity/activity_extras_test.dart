import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/activity/activity.dart';

void main() {
  test('test creating extras object', () {
    final jsonString =
        '''{\"startTimeExtraAlarm\":\"abcdef\",\"startTimeExtraAlarmFileId\":\"ghijkl\",\"endTimeExtraAlarm\":\"mnopqrs\",\"endTimeExtraAlarmFileId\":\"tuvwxyz\"}''';

    final extras = Extras.createNew(
      startTimeExtraAlarm: 'abcdef',
      startTimeExtraAlarmFileId: 'ghijkl',
      endTimeExtraAlarm: 'mnopqrs',
      endTimeExtraAlarmFileId: 'tuvwxyz',
    );

    expect(extras.startTimeExtraAlarm, 'abcdef');
    expect(extras.startTimeExtraAlarmFileId, 'ghijkl');
    expect(extras.endTimeExtraAlarm, 'mnopqrs');
    expect(extras.endTimeExtraAlarmFileId, 'tuvwxyz');
    expect(extras.toJsonString(), jsonString);
  });

  test('test json parsing', () {
    final jsonString =
        '''{\"startTimeExtraAlarm\":\"/handi/user/voicenotes/voice_recording_30ee75a1-6c2f-4fcd-9f06-d2365e6012b0.wav\",\"startTimeExtraAlarmFileId\":\"30ee75a1-6c2f-4fcd-9f06-d2365e6012b0\",\"endTimeExtraAlarm\":\"higjhvvh\",\"endTimeExtraAlarmFileId\":\"734871297863\"}''';

    final extras = Extras.fromJsonString(jsonString);

    expect(extras.startTimeExtraAlarm,
        '/handi/user/voicenotes/voice_recording_30ee75a1-6c2f-4fcd-9f06-d2365e6012b0.wav');
    expect(extras.startTimeExtraAlarmFileId,
        '30ee75a1-6c2f-4fcd-9f06-d2365e6012b0');
    expect(extras.endTimeExtraAlarm, 'higjhvvh');
    expect(extras.endTimeExtraAlarmFileId, '734871297863');
    expect(extras.toJsonString(), jsonString);
  });

  test('test changing value', () {
    final jsonString =
        '''{\"startTimeExtraAlarm\":\"/handi/user/voicenotes/voice_recording_30ee75a1-6c2f-4fcd-9f06-d2365e6012b0.wav\",\"startTimeExtraAlarmFileId\":\"30ee75a1-6c2f-4fcd-9f06-d2365e6012b0\",\"endTimeExtraAlarm\":\"higjhvvh\",\"endTimeExtraAlarmFileId\":\"734871297863\"}''';
    final modifiendJsonString =
        '''{\"startTimeExtraAlarm\":\"new startTimeExtraAlarm\",\"startTimeExtraAlarmFileId\":\"30ee75a1-6c2f-4fcd-9f06-d2365e6012b0\",\"endTimeExtraAlarm\":\"higjhvvh\",\"endTimeExtraAlarmFileId\":\"734871297863\"}''';

    final extras = Extras.fromJsonString(jsonString);

    var extrasChanged =
        extras.copyWith(startTimeExtraAlarm: 'new startTimeExtraAlarm');
    expect(extrasChanged.startTimeExtraAlarm, 'new startTimeExtraAlarm');
    expect(extrasChanged.toJsonString(), modifiendJsonString);
  });

  test('test removing value', () {
    final jsonString =
        '''{\"startTimeExtraAlarm\":\"/handi/user/voicenotes/voice_recording_30ee75a1-6c2f-4fcd-9f06-d2365e6012b0.wav\",\"startTimeExtraAlarmFileId\":\"30ee75a1-6c2f-4fcd-9f06-d2365e6012b0\",\"endTimeExtraAlarm\":\"higjhvvh\",\"endTimeExtraAlarmFileId\":\"734871297863\"}''';
    final modifiendJsonString =
        '''{\"startTimeExtraAlarmFileId\":\"30ee75a1-6c2f-4fcd-9f06-d2365e6012b0\",\"endTimeExtraAlarm\":\"higjhvvh\",\"endTimeExtraAlarmFileId\":\"734871297863\"}''';

    final extras = Extras.fromJsonString(jsonString);

    var extrasChanged = extras.copyWith(startTimeExtraAlarm: '');
    expect(extrasChanged.startTimeExtraAlarm, '');
    expect(extrasChanged.toJsonString(), modifiendJsonString);
  });

  test('test from Extras.empty', () {
    final jsonString =
        '''{\"startTimeExtraAlarm\":\"abcdef\",\"startTimeExtraAlarmFileId\":\"ghijkl\",\"endTimeExtraAlarm\":\"mnopqrs\",\"endTimeExtraAlarmFileId\":\"tuvwxyz\"}''';

    final extras = Extras.empty;

    var extrasChanged = extras.copyWith(
      startTimeExtraAlarm: 'abcdef',
      startTimeExtraAlarmFileId: 'ghijkl',
      endTimeExtraAlarm: 'mnopqrs',
      endTimeExtraAlarmFileId: 'tuvwxyz',
    );

    expect(extrasChanged.startTimeExtraAlarm, 'abcdef');
    expect(extrasChanged.startTimeExtraAlarmFileId, 'ghijkl');
    expect(extrasChanged.endTimeExtraAlarm, 'mnopqrs');
    expect(extrasChanged.endTimeExtraAlarmFileId, 'tuvwxyz');
    expect(extrasChanged.toJsonString(), jsonString);
  });
}
