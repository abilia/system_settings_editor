import 'package:flutter/widgets.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

extension AlarmTypeExtensions on Alarm {
  IconData iconData() {
    if (sound) return AbiliaIcons.handi_alarm_vibration;
    if (vibrate) return AbiliaIcons.handi_vibration;
    return AbiliaIcons.handi_no_alarm_vibration;
  }

  String text(Translated translator) {
    if (sound) return translator.alarmAndVibration;
    if (vibrate) return translator.vibration;
    return translator.noAlarm;
  }
}
