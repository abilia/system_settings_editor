import 'package:seagull/i18n/all.dart';
import 'package:seagull/utils/all.dart';

enum AlarmDuration {
  Alert,
  FifteenSeconds,
  ThirtySeconds,
  OneMinute,
  TwoMinutes,
  FiveMinutes,
}

extension AlarmDurationExtension on AlarmDuration {
  String displayText(Translated t) {
    switch (this) {
      case AlarmDuration.Alert:
        return t.alert;
      case AlarmDuration.FifteenSeconds:
        return '15 ${t.seconds}';
      case AlarmDuration.ThirtySeconds:
        return '30 ${t.seconds}';
      case AlarmDuration.OneMinute:
        return '1 ${t.minute}';
      case AlarmDuration.TwoMinutes:
        return '2 ${t.minutes}';
      case AlarmDuration.FiveMinutes:
        return '5 ${t.minutes}';
      default:
        throw Exception();
    }
  }

  int milliseconds() {
    switch (this) {
      case AlarmDuration.Alert:
        return 0;
      case AlarmDuration.FifteenSeconds:
        return 15.seconds().inMilliseconds;
      case AlarmDuration.ThirtySeconds:
        return 30.seconds().inMilliseconds;
      case AlarmDuration.OneMinute:
        return 1.minutes().inMilliseconds;
      case AlarmDuration.TwoMinutes:
        return 2.minutes().inMilliseconds;
      case AlarmDuration.FiveMinutes:
        return 5.minutes().inMilliseconds;
      default:
        throw Exception();
    }
  }
}

extension ToAlarmDurationExtension on int {
  AlarmDuration toAlarmDuration() {
    if (this <= 0) {
      return AlarmDuration.Alert;
    }
    if (this <= 15000) {
      return AlarmDuration.FifteenSeconds;
    }
    if (this <= 30000) {
      return AlarmDuration.ThirtySeconds;
    }
    if (this <= 60000) {
      return AlarmDuration.OneMinute;
    }
    if (this <= 120000) {
      return AlarmDuration.TwoMinutes;
    }
    return AlarmDuration.FiveMinutes;
  }
}
