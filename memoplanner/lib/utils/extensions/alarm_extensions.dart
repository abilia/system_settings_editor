import 'package:flutter/widgets.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

extension AlarmTypeExtensions on Alarm {
  IconData iconData() {
    if (sound) return AbiliaIcons.handiAlarmVibration;
    if (vibrate) return AbiliaIcons.handiVibration;
    if (silent) return AbiliaIcons.handiAlarm;
    return AbiliaIcons.handiNoAlarmVibration;
  }

  String text(Translated translator) {
    if (sound) return translator.alarmAndVibration;
    if (vibrate) return translator.vibrationIfAvailable;
    if (silent) return translator.silentAlarm;
    return translator.noAlarm;
  }
}
