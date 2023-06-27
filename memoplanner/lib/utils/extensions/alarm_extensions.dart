import 'package:flutter/widgets.dart';
import 'package:memoplanner/l10n/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/components/all.dart';

extension AlarmTypeExtensions on Alarm {
  IconData iconData() {
    if (sound) return AbiliaIcons.handiAlarmVibration;
    if (vibrate) return AbiliaIcons.handiVibration;
    if (silent) return AbiliaIcons.handiAlarm;
    return AbiliaIcons.handiNoAlarmVibration;
  }

  String text(Lt translate) {
    if (sound) return translate.alarmAndVibration;
    if (vibrate) return translate.vibrationIfAvailable;
    if (silent) return translate.silentAlarm;
    return translate.noAlarm;
  }
}
