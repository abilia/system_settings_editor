import 'package:memoplanner/i18n/all.dart';
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
  String displayText(Translated t) {
    switch (this) {
      case AlarmDuration.alert:
        return t.alert;
      case AlarmDuration.fifteenSeconds:
        return '15 ${t.seconds}';
      case AlarmDuration.thirtySeconds:
        return '30 ${t.seconds}';
      case AlarmDuration.oneMinute:
        return '1 ${t.minute}';
      case AlarmDuration.twoMinutes:
        return '2 ${t.minutes}';
      case AlarmDuration.fiveMinutes:
        return '5 ${t.minutes}';
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
