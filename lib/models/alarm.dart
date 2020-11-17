import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Alarm extends Equatable {
  final AlarmType type;
  final bool onlyStart;
  Alarm({@required this.type, this.onlyStart = false})
      : assert(onlyStart != null),
        assert(type != null);
  Alarm copyWith({AlarmType type, bool onlyStart}) =>
      Alarm(type: type ?? this.type, onlyStart: onlyStart ?? this.onlyStart);
  factory Alarm.fromInt(int value) {
    switch (value) {
      case ALARM_SOUND_AND_VIBRATION:
        return Alarm(type: AlarmType.SoundAndVibration);
      case ALARM_SOUND:
        return Alarm(type: AlarmType.Sound);
      case ALARM_VIBRATION:
        return Alarm(type: AlarmType.Vibration);
      case ALARM_SILENT:
        return Alarm(type: AlarmType.Silent);
      case ALARM_SOUND_AND_VIBRATION_ONLY_ON_START:
        return Alarm(type: AlarmType.SoundAndVibration, onlyStart: true);
      case ALARM_SOUND_ONLY_ON_START:
        return Alarm(type: AlarmType.Sound, onlyStart: true);
      case ALARM_VIBRATION_ONLY_ON_START:
        return Alarm(type: AlarmType.Vibration, onlyStart: true);
      case ALARM_SILENT_ONLY_ON_START:
        return Alarm(type: AlarmType.Silent, onlyStart: true);
      case NO_ALARM:
      default:
        return Alarm(type: AlarmType.NoAlarm, onlyStart: true);
    }
  }
  bool get vibrate =>
      type == AlarmType.SoundAndVibration || type == AlarmType.Vibration;
  bool get sound =>
      type == AlarmType.SoundAndVibration || type == AlarmType.Sound;
  bool get silent => type == AlarmType.Silent;
  bool get shouldAlarm => type != AlarmType.NoAlarm;
  bool get atEnd => !onlyStart;
  int get toInt {
    if (onlyStart) {
      switch (type) {
        case AlarmType.SoundAndVibration:
          return ALARM_SOUND_AND_VIBRATION_ONLY_ON_START;
        case AlarmType.Sound:
          return ALARM_SOUND_ONLY_ON_START;
        case AlarmType.Vibration:
          return ALARM_VIBRATION_ONLY_ON_START;
        case AlarmType.Silent:
          return ALARM_SILENT_ONLY_ON_START;
        case AlarmType.NoAlarm:
          return NO_ALARM;
      }
    }
    switch (type) {
      case AlarmType.SoundAndVibration:
        return ALARM_SOUND_AND_VIBRATION;
      case AlarmType.Sound:
        return ALARM_SOUND;
      case AlarmType.Vibration:
        return ALARM_VIBRATION;
      case AlarmType.Silent:
        return ALARM_SILENT;
      case AlarmType.NoAlarm:
        return NO_ALARM;
    }
    return NO_ALARM;
  }

  AlarmType get typeSeagull {
    switch (type) {
      case AlarmType.Sound:
        return AlarmType.SoundAndVibration;
      default:
        return type;
    }
  }

  @override
  String toString() => '$type + ${(atEnd ? ' only start' : '')}';

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

enum AlarmType {
  SoundAndVibration,
  Sound,
  Vibration,
  Silent,
  NoAlarm,
}
