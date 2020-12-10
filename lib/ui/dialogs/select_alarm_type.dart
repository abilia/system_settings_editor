import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class _SelectAlarmTypeDialog extends StatelessWidget {
  final AlarmType alarm;
  final ValueChanged<AlarmType> onChanged;
  final List<Widget> trailing;
  final GestureTapCallback onOk;

  const _SelectAlarmTypeDialog(
      {Key key,
      @required this.alarm,
      @required this.onChanged,
      this.trailing = const <Widget>[],
      this.onOk})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return ViewDialog(
      heading:
          Text(translate.selectAlarmType, style: theme.textTheme.headline6),
      onOk: onOk,
      leftPadding: 0.0,
      rightPadding: 0.0,
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ...[
              if (memoSettingsState.activityDisplayAlarmOption)
                AlarmType.SoundAndVibration,
              if (memoSettingsState.activityDisplaySilentAlarmOption) ...[
                AlarmType.Vibration,
                AlarmType.Silent,
              ],
              if (memoSettingsState.activityDisplayNoAlarmOption)
                AlarmType.NoAlarm,
            ].map((type) => Alarm(type: type)).map(
                  (alarmType) => RadioField(
                    key: ObjectKey(alarmType.typeSeagull),
                    groupValue: alarm,
                    onChanged: onChanged,
                    value: alarmType.typeSeagull,
                    leading: Icon(
                      alarmType.iconData(),
                      size: smallIconSize,
                    ),
                    text: Text(alarmType.text(translate)),
                  ),
                ),
            ...trailing
          ]
              .map((widget) => widget is Divider
                  ? widget
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: ViewDialog.leftPadding,
                        right: ViewDialog.rightPadding,
                        bottom: 8.0,
                      ),
                      child: widget,
                    ))
              .toList(),
        ),
      ),
    );
  }
}

class SelectAlarmTypeDialog extends StatelessWidget {
  final AlarmType alarm;

  const SelectAlarmTypeDialog({Key key, @required this.alarm})
      : super(key: key);
  @override
  Widget build(BuildContext context) => _SelectAlarmTypeDialog(
      alarm: alarm, onChanged: Navigator.of(context).maybePop);
}

class SelectAlarmDialog extends StatefulWidget {
  final Alarm alarm;

  const SelectAlarmDialog({Key key, @required this.alarm}) : super(key: key);

  @override
  _SelectAlarmDialogState createState() => _SelectAlarmDialogState(alarm);
}

class _SelectAlarmDialogState extends State<SelectAlarmDialog> {
  Alarm alarm;

  _SelectAlarmDialogState(this.alarm);
  @override
  Widget build(BuildContext context) {
    return _SelectAlarmTypeDialog(
      alarm: alarm.typeSeagull,
      onOk: alarm != widget.alarm
          ? () => Navigator.of(context).maybePop(alarm)
          : null,
      onChanged: _changeType,
      trailing: [
        const SizedBox(height: ViewDialog.seperatorPadding),
        const Divider(),
        const SizedBox(height: ViewDialog.seperatorPadding),
        AlarmOnlyAtStartSwitch(
          alarm: alarm,
          onChanged: _changeStartTime,
        )
      ],
    );
  }

  void _changeType(AlarmType type) =>
      setState(() => alarm = alarm.copyWith(type: type));
  void _changeStartTime(bool onStart) =>
      setState(() => alarm = alarm.copyWith(onlyStart: onStart));
}
