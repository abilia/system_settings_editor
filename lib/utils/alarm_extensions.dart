import 'package:flutter/widgets.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

extension AlarmTypeExtensions on AlarmType {
  IconData iconData() {
    if (this.sound) return AbiliaIcons.handi_alarm_vibration;
    if (this.vibrate) return AbiliaIcons.handi_vibration;
    return AbiliaIcons.handi_no_alarm_vibration;
  }

  String text(Translated translator) {
    if (this.sound) return translator.alarmAndVibration;
    if (this.vibrate) return translator.vibration;
    return translator.noAlarm;
  }
}
