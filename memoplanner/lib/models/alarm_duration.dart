import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

enum AlarmDuration {
  alert,
  fifteenSeconds,
  thirtySeconds,
  oneMinute,
  twoMinutes,
  fiveMinutes,
}

extension AlarmDurationExtension on AlarmDuration {
  String displayText(Lt translate) {
    switch (this) {
      case AlarmDuration.alert:
        return translate.alert;
      case AlarmDuration.fifteenSeconds:
        return '15 ${translate.seconds}';
      case AlarmDuration.thirtySeconds:
        return '30 ${translate.seconds}';
      case AlarmDuration.oneMinute:
        return '1 ${translate.minute}';
      case AlarmDuration.twoMinutes:
        return '2 ${translate.minutes}';
      case AlarmDuration.fiveMinutes:
        return '5 ${translate.minutes}';
      default:
        throw Exception();
    }
  }

  int milliseconds() => duration().inMilliseconds;

  Duration duration() {
    switch (this) {
      case AlarmDuration.alert:
        return Duration.zero;
      case AlarmDuration.fifteenSeconds:
        return 15.seconds();
      case AlarmDuration.thirtySeconds:
        return 30.seconds();
      case AlarmDuration.oneMinute:
        return 1.minutes();
      case AlarmDuration.twoMinutes:
        return 2.minutes();
      case AlarmDuration.fiveMinutes:
        return 5.minutes();
      default:
        throw Exception();
    }
  }
}

extension ToAlarmDurationExtension on int {
  AlarmDuration toAlarmDuration() {
    if (this <= 0) {
      return AlarmDuration.alert;
    }
    if (this <= 15000) {
      return AlarmDuration.fifteenSeconds;
    }
    if (this <= 30000) {
      return AlarmDuration.thirtySeconds;
    }
    if (this <= 60000) {
      return AlarmDuration.oneMinute;
    }
    if (this <= 120000) {
      return AlarmDuration.twoMinutes;
    }
    return AlarmDuration.fiveMinutes;
  }
}
