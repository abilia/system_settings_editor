import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/alarm_type.dart';

void main() {
  fromIntSameAsToInt(int value) {
    final at = AlarmType.fromInt(value);
    expect(at.toInt, value);
  }

  test('alarmType fromInt same as toInt', () {
    fromIntSameAsToInt(ALARM_SOUND_AND_VIBRATION);
    fromIntSameAsToInt(ALARM_SOUND_AND_VIBRATION_ONLY_ON_START);
    fromIntSameAsToInt(ALARM_SOUND_ONLY_ON_START);
    fromIntSameAsToInt(ALARM_SOUND);
    fromIntSameAsToInt(ALARM_VIBRATION_ONLY_ON_START);
    fromIntSameAsToInt(ALARM_VIBRATION);
    fromIntSameAsToInt(ALARM_SILENT_ONLY_ON_START);
    fromIntSameAsToInt(ALARM_SILENT);
    fromIntSameAsToInt(NO_ALARM);
  });

  test('Changing on end time', () {
    var at = AlarmType.fromInt(ALARM_SOUND_AND_VIBRATION);
    at = at.copyWith(onlyStart: true);
    expect(at.toInt, ALARM_SOUND_AND_VIBRATION_ONLY_ON_START);
  });

  test('Changing alarm type', () {
    var at = AlarmType.fromInt(ALARM_SOUND_AND_VIBRATION);
    at = at.copyWith(type: Alarm.Silent);
    expect(at.toInt, ALARM_SILENT);
  });
}
