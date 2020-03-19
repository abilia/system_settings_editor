import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class _SelectAlarmTypeDialog extends StatelessWidget {
  final Alarm alarm;
  final ValueChanged<Alarm> onChanged;
  final Widget trailing;
  final GestureTapCallback onOk;

  const _SelectAlarmTypeDialog(
      {Key key,
      @required this.alarm,
      @required this.onChanged,
      this.trailing,
      this.onOk})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading: Text(translate.selectAlarmType, style: theme.textTheme.title),
      onOk: onOk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RadioField(
            groupValue: alarm,
            onChanged: onChanged,
            value: Alarm.SoundAndVibration,
            leading: Icon(AbiliaIcons.handi_alarm_vibration),
            label: Text(translate.alarmAndVibration),
          ),
          const SizedBox(height: 8.0),
          RadioField(
            key: TestKey.vibrationAlarm,
            groupValue: alarm,
            onChanged: onChanged,
            value: Alarm.Vibration,
            leading: Icon(AbiliaIcons.handi_vibration),
            label: Text(translate.vibration),
          ),
          const SizedBox(height: 8.0),
          RadioField(
            groupValue: alarm,
            onChanged: onChanged,
            value: Alarm.NoAlarm,
            leading: Icon(AbiliaIcons.handi_no_alarm_vibration),
            label: Text(translate.noAlarm),
          ),
        ],
      ),
      trailing: trailing,
    );
  }
}

class SelectAlarmTypeDialog extends StatelessWidget {
  final Alarm alarm;

  const SelectAlarmTypeDialog({Key key, @required this.alarm})
      : super(key: key);
  @override
  Widget build(BuildContext context) => _SelectAlarmTypeDialog(
      alarm: alarm, onChanged: Navigator.of(context).maybePop);
}

class SelectAlarmDialog extends StatefulWidget {
  final AlarmType alarm;

  const SelectAlarmDialog({Key key, @required this.alarm}) : super(key: key);

  @override
  _SelectAlarmDialogState createState() => _SelectAlarmDialogState(alarm);
}

class _SelectAlarmDialogState extends State<SelectAlarmDialog> {
  AlarmType alarm;

  _SelectAlarmDialogState(this.alarm);
  @override
  Widget build(BuildContext context) {
    return _SelectAlarmTypeDialog(
      alarm: alarm.type,
      onOk: alarm != widget.alarm
          ? () => Navigator.of(context).maybePop(alarm)
          : null,
      onChanged: _changeType,
      trailing: AlarmOnlyAtStartSwitch(
        alarm: alarm,
        onChanged: _changeStartTime,
      ),
    );
  }

  _changeType(Alarm type) => setState(() => alarm = alarm.copyWith(type: type));
  _changeStartTime(bool onStart) =>
      setState(() => alarm = alarm.copyWith(onlyStart: onStart));
}
