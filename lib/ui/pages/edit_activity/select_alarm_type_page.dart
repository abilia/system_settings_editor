import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class _SelectAlarmTypePage extends StatelessWidget {
  final AlarmType alarm;
  final ValueChanged<AlarmType?> onChanged;
  final List<Widget> trailing;
  final GestureTapCallback? onOk;

  const _SelectAlarmTypePage({
    Key? key,
    required this.alarm,
    required this.onChanged,
    this.trailing = const <Widget>[],
    this.onOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.selectAlarmType,
        iconData: AbiliaIcons.handiAlarmVibration,
      ),
      body: SelectAlarmTypeBody(
          alarm: alarm, trailing: trailing, onChanged: onChanged),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: onOk,
        ),
      ),
    );
  }
}

class SelectAlarmTypeBody extends StatelessWidget {
  final AlarmType alarm;
  final ValueChanged<AlarmType?> onChanged;
  final List<Widget> trailing;

  const SelectAlarmTypeBody(
      {Key? key,
      required this.alarm,
      required this.onChanged,
      required this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => ScrollArrows.vertical(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          padding:
              EdgeInsets.only(top: 24.0.s).add(EditActivityTab.bottomPadding),
          children: <Widget>[
            ...[
              if (memoSettingsState.activityDisplayAlarmOption)
                AlarmType.soundAndVibration,
              if (memoSettingsState.activityDisplaySilentAlarmOption) ...[
                AlarmType.vibration,
                AlarmType.silent,
              ],
              if (memoSettingsState.activityDisplayNoAlarmOption)
                AlarmType.noAlarm,
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
              .map(
                (widget) => widget is Divider
                    ? widget
                    : Padding(
                        padding: EdgeInsets.only(
                          left: leftPadding,
                          right: rightPadding,
                          bottom: 8.0.s,
                        ),
                        child: widget,
                      ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class SelectAlarmTypePage extends StatefulWidget {
  final AlarmType alarm;

  const SelectAlarmTypePage({Key? key, required this.alarm}) : super(key: key);

  @override
  _SelectAlarmTypePageState createState() => _SelectAlarmTypePageState();
}

class _SelectAlarmTypePageState extends State<SelectAlarmTypePage> {
  late AlarmType newAlarm;

  @override
  void initState() {
    super.initState();
    newAlarm = widget.alarm;
  }

  @override
  Widget build(BuildContext context) => _SelectAlarmTypePage(
      alarm: newAlarm,
      onOk: newAlarm != widget.alarm
          ? () => Navigator.of(context).maybePop(newAlarm)
          : null,
      onChanged: (v) {
        if (v != null) setState(() => newAlarm = v);
      });
}

class SelectAlarmPage extends StatefulWidget {
  final Activity activity;

  const SelectAlarmPage({Key? key, required this.activity}) : super(key: key);

  @override
  _SelectAlarmPageState createState() => _SelectAlarmPageState();
}

class _SelectAlarmPageState extends State<SelectAlarmPage> {
  late Activity activity;

  @override
  void initState() {
    super.initState();
    activity = widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    return _SelectAlarmTypePage(
      alarm: activity.alarm.typeSeagull,
      onOk: activity != widget.activity
          ? () => Navigator.of(context).maybePop(activity)
          : null,
      onChanged: _changeType,
      trailing: [
        const SizedBox(),
        const Divider(),
        SizedBox(height: 8.s),
        AlarmOnlyAtStartSwitch(
          alarm: activity.alarm,
          onChanged: _changeStartTime,
        ),
        SizedBox(height: 8.s),
        const Divider(),
        SizedBox(height: 24.s),
        RecordSoundWidget(activity: activity, soundChanged: _changeRecording),
      ],
    );
  }

  void _changeType(AlarmType? type) => setState(() {
        activity =
            activity.copyWith(alarm: activity.alarm.copyWith(type: type));
      });

  void _changeStartTime(bool onStart) => setState(() {
        activity = activity.copyWith(
            alarm: activity.alarm.copyWith(onlyStart: onStart));
      });

  void _changeRecording(Activity newActivity) =>
      setState(() => activity = activity.copyActivity(newActivity));
}
