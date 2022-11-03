import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/alarm.dart';

void main() {
  void fromIntSameAsToInt(int value) =>
      expect(Alarm.fromInt(value).intValue, value);

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
    expect(at.intValue, alarmSoundAndVibrationOnlyOnStart);
  });

  test('Changing alarm type', () {
    var at = Alarm.fromInt(alarmSoundAndVibration);
    at = at.copyWith(type: AlarmType.silent);
    expect(at.intValue, alarmSilent);
  });
}
