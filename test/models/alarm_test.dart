import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/alarm.dart';

void main() {
  void fromIntSameAsToInt(int value) =>
      expect(Alarm.fromInt(value).toInt, value);

  test('alarmType fromInt same as toInt', () {
    fromIntSameAsToInt(alarmSoundAndVibration);
    fromIntSameAsToInt(alarmSoundAndVibrationOnlyOnStart);
    fromIntSameAsToInt(alarmSoundOnlyOnStart);
    fromIntSameAsToInt(alarmSound);
    fromIntSameAsToInt(alarmVibrationOnlyOnStart);
    fromIntSameAsToInt(alarmVibration);
    fromIntSameAsToInt(alarmSilentOnlyOnStart);
    fromIntSameAsToInt(alarmSilent);
    fromIntSameAsToInt(noAlarm);
  });

  test('Changing on end time', () {
    var at = Alarm.fromInt(alarmSoundAndVibration);
    at = at.copyWith(onlyStart: true);
    expect(at.toInt, alarmSoundAndVibrationOnlyOnStart);
  });

  test('Changing alarm type', () {
    var at = Alarm.fromInt(alarmSoundAndVibration);
    at = at.copyWith(type: AlarmType.silent);
    expect(at.toInt, alarmSilent);
  });
}
