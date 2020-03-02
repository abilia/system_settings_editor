import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class SelectAlarmTypeDialog extends StatelessWidget {
  final Alarm alarm;

  const SelectAlarmTypeDialog({Key key, @required this.alarm})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(translate.selectAlarmType, style: theme.textTheme.title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RadioField(
            groupValue: alarm,
            onChanged: Navigator.of(context).maybePop,
            value: Alarm.SoundAndVibration,
            leading: Icon(AbiliaIcons.handi_alarm_vibration),
            label: Text(translate.alarmAndVibration),
          ),
          SizedBox(height: 8.0),
          RadioField(
            key: TestKey.vibrationAlarm,
            groupValue: alarm,
            onChanged: Navigator.of(context).maybePop,
            value: Alarm.Vibration,
            leading: Icon(AbiliaIcons.handi_vibration),
            label: Text(translate.vibration),
          ),
          SizedBox(height: 8.0),
          RadioField(
            groupValue: alarm,
            onChanged: Navigator.of(context).maybePop,
            value: Alarm.NoAlarm,
            leading: Icon(AbiliaIcons.handi_no_alarm_vibration),
            label: Text(translate.noAlarm),
          ),
        ],
      ),
    );
  }
}
