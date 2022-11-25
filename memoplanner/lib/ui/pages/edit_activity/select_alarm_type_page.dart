import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class _SelectAlarmTypePage extends StatelessWidget {
  final AlarmType alarm;
  final ValueChanged<AlarmType?> onChanged;
  final List<Widget> trailing;
  final GestureTapCallback? onOk;
  final bool Function() discardDialogCondition;

  const _SelectAlarmTypePage({
    required this.alarm,
    required this.onChanged,
    required this.discardDialogCondition,
    this.trailing = const <Widget>[],
    this.onOk,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return PopAwareDiscardListener(
      discardDialogCondition: (_) => discardDialogCondition(),
      child: Scaffold(
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
      ),
    );
  }
}

class SelectAlarmTypeBody extends StatelessWidget {
  final AlarmType alarm;
  final ValueChanged<AlarmType?> onChanged;
  final List<Widget> trailing;

  const SelectAlarmTypeBody({
    required this.alarm,
    required this.onChanged,
    required this.trailing,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final translate = Translator.of(context).translate;
    final generalSettings = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.addActivity.general);
    return ScrollArrows.vertical(
      controller: scrollController,
      child: ListView(
        controller: scrollController,
        padding: layout.templates.m1.onlyVertical,
        children: <Widget>[
          ...[
            if (generalSettings.showAlarm) AlarmType.soundAndVibration,
            if (generalSettings.showVibrationAlarm) AlarmType.vibration,
            if (generalSettings.showSilentAlarm) AlarmType.silent,
            if (generalSettings.showNoAlarm) AlarmType.noAlarm,
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
                        left: layout.templates.m1.left,
                        right: layout.templates.m1.right,
                        bottom: layout.formPadding.verticalItemDistance,
                      ),
                      child: widget,
                    ),
            )
            .toList(),
      ),
    );
  }
}

class SelectAlarmTypePage extends StatefulWidget {
  final AlarmType alarm;

  const SelectAlarmTypePage({
    required this.alarm,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _SelectAlarmTypePageState();
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
      discardDialogCondition: () => false,
      onOk: newAlarm != widget.alarm
          ? () => Navigator.of(context).maybePop(newAlarm)
          : null,
      onChanged: (v) {
        if (v != null) setState(() => newAlarm = v);
      });
}

class SelectAlarmPage extends StatefulWidget {
  final Activity activity;

  const SelectAlarmPage({
    required this.activity,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _SelectAlarmPageState();
}

class _SelectAlarmPageState extends State<SelectAlarmPage> {
  late Activity _activity, _originalActivity;

  @override
  void initState() {
    super.initState();
    _activity = widget.activity;
    _originalActivity = _activity;
  }

  bool get unchanged => _originalActivity == _activity;

  @override
  Widget build(BuildContext context) {
    return _SelectAlarmTypePage(
      alarm: _activity.alarm.typeSeagull,
      discardDialogCondition: () => _originalActivity != _activity,
      onOk: !unchanged ? _onOk : null,
      onChanged: _changeType,
      trailing: [
        const SizedBox(),
        const Divider(),
        SizedBox(height: layout.formPadding.verticalItemDistance),
        AlarmOnlyAtStartSwitch(
          alarm: _activity.alarm,
          onChanged: _changeStartTime,
        ),
        SizedBox(height: layout.formPadding.verticalItemDistance),
        const Divider(),
        SizedBox(height: layout.formPadding.groupTopDistance),
        RecordSoundWidget(activity: _activity, soundChanged: _changeRecording),
      ],
    );
  }

  void _onOk() {
    _originalActivity = _activity;
    Navigator.of(context).maybePop(_activity);
  }

  void _changeType(AlarmType? type) => setState(() {
        _activity =
            _activity.copyWith(alarm: _activity.alarm.copyWith(type: type));
      });

  void _changeStartTime(bool onStart) => setState(() {
        _activity = _activity.copyWith(
            alarm: _activity.alarm.copyWith(onlyStart: onStart));
      });

  void _changeRecording(Activity newActivity) =>
      setState(() => _activity = _activity.copyActivity(newActivity));
}
