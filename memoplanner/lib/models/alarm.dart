import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final AlarmType type;
  final bool onlyStart;

  const Alarm({
    required this.type,
    this.onlyStart = false,
  });

  Alarm copyWith({AlarmType? type, bool? onlyStart}) =>
      Alarm(type: type ?? this.type, onlyStart: onlyStart ?? this.onlyStart);

  factory Alarm.fromInt(int value) {
    switch (value) {
      case alarmSoundAndVibration:
        return const Alarm(type: AlarmType.soundAndVibration);
      case alarmSound:
        return const Alarm(type: AlarmType.sound);
      case alarmVibration:
        return const Alarm(type: AlarmType.vibration);
      case alarmSilent:
        return const Alarm(type: AlarmType.silent);
      case noAlarm:
        return const Alarm(type: AlarmType.noAlarm);
      case alarmSoundAndVibrationOnlyOnStart:
        return const Alarm(type: AlarmType.soundAndVibration, onlyStart: true);
      case alarmSoundOnlyOnStart:
        return const Alarm(type: AlarmType.sound, onlyStart: true);
      case alarmVibrationOnlyOnStart:
        return const Alarm(type: AlarmType.vibration, onlyStart: true);
      case alarmSilentOnlyOnStart:
        return const Alarm(type: AlarmType.silent, onlyStart: true);
      default:
        return const Alarm(type: AlarmType.noAlarm, onlyStart: true);
    }
  }

  bool get vibrate =>
      type == AlarmType.soundAndVibration || type == AlarmType.vibration;

  bool get sound =>
      type == AlarmType.soundAndVibration || type == AlarmType.sound;

  bool get silent => type == AlarmType.silent;

  bool get shouldAlarm => type != AlarmType.noAlarm;

  bool get atEnd => !onlyStart;

  int get intValue {
    if (onlyStart) {
      switch (type) {
        case AlarmType.soundAndVibration:
          return alarmSoundAndVibrationOnlyOnStart;
        case AlarmType.sound:
          return alarmSoundOnlyOnStart;
        case AlarmType.vibration:
          return alarmVibrationOnlyOnStart;
        case AlarmType.silent:
          return alarmSilentOnlyOnStart;
        case AlarmType.noAlarm:
          return noAlarmOnlyOnStart;
      }
    }
    switch (type) {
      case AlarmType.soundAndVibration:
        return alarmSoundAndVibration;
      case AlarmType.sound:
        return alarmSound;
      case AlarmType.vibration:
        return alarmVibration;
      case AlarmType.silent:
        return alarmSilent;
      case AlarmType.noAlarm:
        return noAlarm;
    }
  }

  AlarmType get typeSeagull {
    switch (type) {
      case AlarmType.sound:
        return AlarmType.soundAndVibration;
      default:
        return type;
    }
  }

  @override
  String toString() => '$type + ${(atEnd ? ' only start' : '')}';

  @override
  List<Object> get props => [onlyStart, type];
}

const int alarmSoundAndVibration = 100,
    alarmSound = 101,
    alarmVibration = 102,
    alarmSilent = 103,
    noAlarm = 104,
    alarmSoundAndVibrationOnlyOnStart = 95,
    alarmSoundOnlyOnStart = 99,
    alarmVibrationOnlyOnStart = 96,
    alarmSilentOnlyOnStart = 98,
    noAlarmOnlyOnStart = 97;

enum AlarmType {
  soundAndVibration,
  sound,
  vibration,
  silent,
  noAlarm,
}
