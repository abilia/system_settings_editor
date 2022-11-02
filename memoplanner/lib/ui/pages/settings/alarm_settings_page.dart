import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmSettingsPage extends StatelessWidget {
  const AlarmSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final defaultPadding = layout.alarmSettingsPage.defaultPadding;
    final topPadding = layout.alarmSettingsPage.topPadding;
    final bottomPadding = layout.alarmSettingsPage.bottomPadding;
    final dividerPadding = layout.alarmSettingsPage.dividerPadding;
    final scrollController = ScrollController();
    final settings = context.read<MemoplannerSettingsBloc>().state;
    return BlocProvider<AlarmSettingsCubit>(
      create: (context) => AlarmSettingsCubit(
        alarmSettings: settings.alarm,
        genericCubit: context.read<GenericCubit>(),
      ),
      child: BlocProvider<AlarmSoundCubit>(
        create: (_) => AlarmSoundCubit(),
        child: BlocBuilder<AlarmSettingsCubit, AlarmSettings>(
          builder: (context, state) {
            return Scaffold(
              appBar: AbiliaAppBar(
                title: t.alarmSettings,
                label: Config.isMP ? t.calendar : null,
                iconData: AbiliaIcons.handiAlarmVibration,
              ),
              body: ScrollArrows.vertical(
                controller: scrollController,
                child: ListView(
                  controller: scrollController,
                  children: [
                    _AlarmSelector(
                      key: TestKey.nonCheckableAlarmSelector,
                      heading: t.nonCheckableActivities,
                      icon: AbiliaIcons.handiUncheck,
                      sound: state.nonCheckableSound,
                      onChanged: (sound) => context
                          .read<AlarmSettingsCubit>()
                          .changeAlarmSettings(
                              state.copyWith(nonCheckableSound: sound)),
                    ).pad(topPadding),
                    _AlarmSelector(
                      key: TestKey.checkableAlarmSelector,
                      heading: t.checkableActivities,
                      icon: AbiliaIcons.handiCheck,
                      sound: state.checkableSound,
                      onChanged: (sound) => context
                          .read<AlarmSettingsCubit>()
                          .changeAlarmSettings(
                              state.copyWith(checkableSound: sound)),
                    ).pad(defaultPadding),
                    _AlarmSelector(
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
                    _AlarmSelector(
                      key: TestKey.timerAlarmSelector,
                      heading: t.timer,
                      icon: AbiliaIcons.stopWatch,
                      sound: state.timerSound,
                      noSoundOption: true,
                      onChanged: (sound) => context
                          .read<AlarmSettingsCubit>()
                          .changeAlarmSettings(
                              state.copyWith(timerSound: sound)),
                    ).pad(defaultPadding),
                    _AlarmDurationSelector(
                      key: TestKey.alarmDurationSelector,
                      duration: state.alarmDuration,
                    ).pad(defaultPadding),
                    if (Config.isMP) const Divider().pad(dividerPadding),
                    if (Config.isMP)
                      SwitchField(
                        key: TestKey.showOngoingActivityInFullScreen,
                        value: state.showOngoingActivityInFullScreen,
                        leading: const Icon(AbiliaIcons.resizeHigher),
                        onChanged: (v) => context
                            .read<AlarmSettingsCubit>()
                            .changeAlarmSettings(state.copyWith(
                                showOngoingActivityInFullScreen: v)),
                        child: Text(t.showOngoingActivityInFullScreen),
                      ).pad(defaultPadding),
                    const Divider().pad(dividerPadding),
                    SwitchField(
                      key: TestKey.showAlarmOnOffSwitch,
                      value: state.showAlarmOnOffSwitch,
                      leading: const Icon(AbiliaIcons.handiNoAlarmVibration),
                      onChanged: (v) => context
                          .read<AlarmSettingsCubit>()
                          .changeAlarmSettings(
                              state.copyWith(showAlarmOnOffSwitch: v)),
                      child: Text(t.showDisableAlarms),
                    ).pad(bottomPadding),
                  ],
                ),
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

class _AlarmSelector extends StatelessWidget {
  final String heading;
  final IconData icon;
  final Sound sound;
  final ValueChanged<Sound> onChanged;
  final bool noSoundOption;

  const _AlarmSelector({
    required this.heading,
    required this.icon,
    required this.sound,
    required this.onChanged,
    this.noSoundOption = false,
    Key? key,
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
                          appBarLabel: Config.isMP
                              ? Translator.of(context).translate.alarmSettings
                              : null,
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
              width: layout.alarmSettingsPage.playButtonSeparation,
            ),
            PlayAlarmSoundButton(sound: sound),
          ],
        ),
      ],
    );
  }
}

class _AlarmDurationSelector extends StatelessWidget {
  final AlarmDuration duration;

  const _AlarmDurationSelector({
    required this.duration,
    Key? key,
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
              final cubit = context.read<AlarmSettingsCubit>();
              final result = await Navigator.of(context).push<AlarmDuration>(
                MaterialPageRoute(
                  builder: (context) => SelectAlarmDurationPage(
                    duration: duration,
                    appBarIcon: AbiliaIcons.stopWatch,
                    appBarTitle: t.alarmTime,
                    appBarLabel: Config.isMP ? t.alarmSettings : null,
                  ),
                ),
              );
              if (result != null && result != duration) {
                cubit.changeAlarmSettings(
                    cubit.state.copyWith(alarmDuration: result));
              }
            }),
      ],
    );
  }
}
