import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class AlarmType extends Equatable {
  final Alarm type;
  final bool onlyStart;
  AlarmType({@required this.type, this.onlyStart = false})
      : assert(onlyStart != null),
        assert(type != null);
  AlarmType copyWith({Alarm type, bool onlyStart}) => AlarmType(
      type: type ?? this.type, onlyStart: onlyStart ?? this.onlyStart);
  factory AlarmType.fromInt(int value) {
    switch (value) {
      case ALARM_SOUND_AND_VIBRATION:
        return AlarmType(type: Alarm.SoundAndVibration);
      case ALARM_SOUND:
        return AlarmType(type: Alarm.Sound);
      case ALARM_VIBRATION:
        return AlarmType(type: Alarm.Vibration);
      case ALARM_SILENT:
        return AlarmType(type: Alarm.Silent);
      case ALARM_SOUND_AND_VIBRATION_ONLY_ON_START:
        return AlarmType(type: Alarm.SoundAndVibration, onlyStart: true);
      case ALARM_SOUND_ONLY_ON_START:
        return AlarmType(type: Alarm.Sound, onlyStart: true);
      case ALARM_VIBRATION_ONLY_ON_START:
        return AlarmType(type: Alarm.Vibration, onlyStart: true);
      case ALARM_SILENT_ONLY_ON_START:
        return AlarmType(type: Alarm.Silent, onlyStart: true);
      case NO_ALARM:
      default:
        return AlarmType(type: Alarm.NoAlarm, onlyStart: true);
    }
  }
  bool get vibrate =>
      type == Alarm.SoundAndVibration ||
      type == Alarm.Vibration ||
      type == Alarm.Silent;
  bool get sound => type == Alarm.SoundAndVibration || type == Alarm.Sound;
  bool get shouldAlarm => type != Alarm.NoAlarm;
  bool get atEnd => !onlyStart;
  int get toInt {
    if (onlyStart) {
      switch (type) {
        case Alarm.SoundAndVibration:
          return ALARM_SOUND_AND_VIBRATION_ONLY_ON_START;
        case Alarm.Sound:
          return ALARM_SOUND_ONLY_ON_START;
        case Alarm.Vibration:
          return ALARM_VIBRATION_ONLY_ON_START;
        case Alarm.Silent:
          return ALARM_SILENT_ONLY_ON_START;
        case Alarm.NoAlarm:
          return NO_ALARM;
      }
    }
    switch (type) {
      case Alarm.SoundAndVibration:
        return ALARM_SOUND_AND_VIBRATION;
      case Alarm.Sound:
        return ALARM_SOUND;
      case Alarm.Vibration:
        return ALARM_VIBRATION;
      case Alarm.Silent:
        return ALARM_SILENT;
      case Alarm.NoAlarm:
        return NO_ALARM;
    }
    return NO_ALARM;
  }

  @override
  String toString() => alarmEnumToString(type) + (atEnd ? ' only start' : '');

  @override
  List<Object> get props => [onlyStart, type];
}

const int ALARM_SOUND_AND_VIBRATION = 100,
    ALARM_SOUND = 101,
    ALARM_VIBRATION = 102,
    ALARM_SILENT = 103,
    NO_ALARM = 104,
    ALARM_SOUND_AND_VIBRATION_ONLY_ON_START = 95,
    ALARM_SOUND_ONLY_ON_START = 99,
    ALARM_VIBRATION_ONLY_ON_START = 96,
    ALARM_SILENT_ONLY_ON_START = 98,
    NO_ALARM_ONLY_ON_START = 97;

String alarmEnumToString(Alarm type) {
  switch (type) {
    case Alarm.SoundAndVibration:
      return 'Sound and vibration';
    case Alarm.Vibration:
      return 'Vibration';
    case Alarm.Silent:
      return 'Silent';
    case Alarm.NoAlarm:
      return 'No alarm';
    case Alarm.Sound:
    default:
      return 'Sound';
  }
}

enum Alarm {
  SoundAndVibration,
  Sound,
  Vibration,
  Silent,
  NoAlarm,
}
