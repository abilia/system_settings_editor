import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class SelectAlarmTypePage extends StatelessWidget {
  final List<Widget> trailing;
  final GestureTapCallback onOk;

  const SelectAlarmTypePage({
    required this.onOk,
    this.trailing = const <Widget>[],
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.selectAlarmType,
        iconData: AbiliaIcons.handiAlarmVibration,
      ),
      body: SelectAlarmTypeBody(trailing: trailing),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(onPressed: onOk),
      ),
    );
  }
}

class SelectAlarmTypeBody extends StatelessWidget {
  final List<Widget> trailing;

  const SelectAlarmTypeBody({
    required this.trailing,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final translate = Translator.of(context).translate;
    final generalSettings = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.addActivity.general);
    final cubit = context.watch<EditActivityCubit>();
    final activity = cubit.state.activity;
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
                  groupValue: activity.alarm.typeSeagull,
                  onChanged: (AlarmType? type) {
                    cubit.replaceActivity(
                      activity.copyWith(
                        alarm: activity.alarm.copyWith(type: type),
                      ),
                    );
                  },
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

class SelectAlarmPage extends StatelessWidget {
  const SelectAlarmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectAlarmTypePage(
      onOk: () => Navigator.of(context)
          .pop(context.read<EditActivityCubit>().state.activity),
      trailing: [
        const SizedBox(),
        const Divider(),
        SizedBox(height: layout.formPadding.verticalItemDistance),
        const AlarmOnlyAtStartSwitch(),
        SizedBox(height: layout.formPadding.verticalItemDistance),
        const Divider(),
        SizedBox(height: layout.formPadding.groupTopDistance),
        const RecordSoundWidget(),
      ],
    );
  }
}
