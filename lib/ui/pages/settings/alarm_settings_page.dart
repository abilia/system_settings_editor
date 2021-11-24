import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmSettingsPage extends StatelessWidget {
  const AlarmSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final defaultPadding = EdgeInsets.fromLTRB(12.s, 16.s, 20.s, 0);
    final topPadding = EdgeInsets.fromLTRB(12.s, 24.s, 20.s, 0);
    return BlocProvider<AlarmSettingsCubit>(
      create: (context) => AlarmSettingsCubit(
        alarmSettings: context.read<MemoplannerSettingBloc>().state.alarm,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: BlocProvider<AlarmSoundCubit>(
        create: (_) => AlarmSoundCubit(),
        child: BlocBuilder<AlarmSettingsCubit, AlarmSettings>(
          builder: (context, state) {
            return Scaffold(
              appBar: AbiliaAppBar(
                title: Translator.of(context).translate.alarmSettings,
                iconData: AbiliaIcons.handiAlarmVibration,
              ),
              body: ListView(
                children: [
                  AlarmSelector(
                    key: TestKey.nonCheckableAlarmSelector,
                    heading: t.nonCheckableActivities,
                    icon: AbiliaIcons.handiUncheck,
                    sound: state.nonCheckableSound,
                    onChanged: (sound) => context
                        .read<AlarmSettingsCubit>()
                        .changeAlarmSettings(
                            state.copyWith(nonCheckableSound: sound)),
                  ).pad(topPadding),
                  AlarmSelector(
                    key: TestKey.checkableAlarmSelector,
                    heading: t.checkableActivities,
                    icon: AbiliaIcons.handiCheck,
                    sound: state.checkableSound,
                    onChanged: (sound) => context
                        .read<AlarmSettingsCubit>()
                        .changeAlarmSettings(
                            state.copyWith(checkableSound: sound)),
                  ).pad(defaultPadding),
                  AlarmSelector(
                    key: TestKey.reminderAlarmSelector,
                    heading: t.reminders,
                    icon: AbiliaIcons.handiReminder,
                    sound: state.reminderSound,
                    noSoundOption: true,
                    onChanged: (sound) => context
                        .read<AlarmSettingsCubit>()
                        .changeAlarmSettings(
                            state.copyWith(reminderSound: sound)),
                  ).pad(defaultPadding),
                  SwitchField(
                    key: TestKey.vibrateAtReminderSelector,
                    value: state.vibrateAtReminder,
                    onChanged: (v) => context
                        .read<AlarmSettingsCubit>()
                        .changeAlarmSettings(
                            state.copyWith(vibrateAtReminder: v)),
                    child: Text(t.vibrationOnReminder),
                  ).pad(defaultPadding),
                  AlarmDurationSelector(
                    key: TestKey.alarmDurationSelector,
                    duration: state.alarmDuration,
                  ).pad(defaultPadding),
                  const Divider().pad(EdgeInsets.only(top: 16.s)),
                  SwitchField(
                    key: TestKey.showAlarmOnOffSwitch,
                    value: state.showAlarmOnOffSwitch,
                    onChanged: (v) => context
                        .read<AlarmSettingsCubit>()
                        .changeAlarmSettings(
                            state.copyWith(showAlarmOnOffSwitch: v)),
                    child: Text(t.showDisableAlarms),
                  ).pad(defaultPadding),
                ],
              ),
              bottomNavigationBar: BottomNavigation(
                backNavigationWidget: const CancelButton(),
                forwardNavigationWidget: OkButton(
                  onPressed: () {
                    context.read<AlarmSettingsCubit>().save();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AlarmSelector extends StatelessWidget {
  final String heading;
  final IconData icon;
  final Sound sound;
  final ValueChanged<Sound> onChanged;
  final bool noSoundOption;
  const AlarmSelector({
    Key? key,
    required this.heading,
    required this.icon,
    required this.sound,
    required this.onChanged,
    this.noSoundOption = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(heading),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: PickField(
                key: TestKey.availibleFor,
                text: Text(sound.displayName(t)),
                onTap: () async {
                  final result = await Navigator.of(context).push<Sound>(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider<AlarmSoundCubit>.value(
                        value: context.read<AlarmSoundCubit>(),
                        child: SelectSoundPage(
                          sound: sound,
                          noSoundOption: noSoundOption,
                          appBarIcon: icon,
                          appBarTitle: heading,
                        ),
                      ),
                    ),
                  );
                  if (result != null && result != sound) {
                    onChanged(result);
                  }
                },
              ),
            ),
            SizedBox(
              width: 12.s,
            ),
            PlayAlarmSoundButton(sound: sound),
          ],
        ),
      ],
    );
  }
}

class AlarmDurationSelector extends StatelessWidget {
  final AlarmDuration duration;
  const AlarmDurationSelector({
    Key? key,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeading(t.alarmTime),
        PickField(
            text: Text(duration.displayText(t)),
            onTap: () async {
              final result = await Navigator.of(context).push<AlarmDuration>(
                MaterialPageRoute(
                  builder: (context) => SelectAlarmDurationPage(
                    duration: duration,
                    appBarIcon: AbiliaIcons.stopWatch,
                    appBarTitle: t.alarmTime,
                  ),
                ),
              );
              if (result != null && result != duration) {
                final cubit = context.read<AlarmSettingsCubit>();
                cubit.changeAlarmSettings(
                    cubit.state.copyWith(alarmDuration: result));
              }
            }),
      ],
    );
  }
}
