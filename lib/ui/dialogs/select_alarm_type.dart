import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class _SelectAlarmTypePage extends StatelessWidget {
  final AlarmType alarm;
  final ValueChanged<AlarmType> onChanged;
  final List<Widget> trailing;
  final GestureTapCallback onOk;

  const _SelectAlarmTypePage(
      {Key key,
      @required this.alarm,
      @required this.onChanged,
      this.trailing = const <Widget>[],
      this.onOk})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: NewAbiliaAppBar(
        title: translate.selectAlarmType,
        iconData: AbiliaIcons.handi_alarm_vibration,
      ),
      body: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) => Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Column(
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
                      leading: Icon(alarmType.iconData()),
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
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: onOk,
        ),
      ),
    );
  }
}

class SelectAlarmTypePage extends StatefulWidget {
  final AlarmType alarm;

  const SelectAlarmTypePage({Key key, @required this.alarm}) : super(key: key);

  @override
  _SelectAlarmTypePageState createState() => _SelectAlarmTypePageState(alarm);
}

class _SelectAlarmTypePageState extends State<SelectAlarmTypePage> {
  AlarmType newAlarm;

  _SelectAlarmTypePageState(this.newAlarm);
  @override
  Widget build(BuildContext context) => _SelectAlarmTypePage(
        alarm: newAlarm,
        onOk: newAlarm != widget.alarm
            ? () => Navigator.of(context).maybePop(newAlarm)
            : null,
        onChanged: (v) {
          setState(() {
            newAlarm = v;
          });
        },
      );
}

class SelectAlarmPage extends StatefulWidget {
  final Alarm alarm;

  const SelectAlarmPage({Key key, @required this.alarm}) : super(key: key);

  @override
  _SelectAlarmPageState createState() => _SelectAlarmPageState(alarm);
}

class _SelectAlarmPageState extends State<SelectAlarmPage> {
  Alarm alarm;

  _SelectAlarmPageState(this.alarm);
  @override
  Widget build(BuildContext context) {
    return _SelectAlarmTypePage(
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
