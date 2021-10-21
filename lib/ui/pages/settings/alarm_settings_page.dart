import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class AlarmSettingsPage extends StatelessWidget {
  const AlarmSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocProvider<AlarmSettingsCubit>(
      create: (context) => AlarmSettingsCubit(
        alarmSettings: context.read<MemoplannerSettingBloc>().state.alarm,
        genericBloc: context.read<GenericBloc>(),
      ),
      child: BlocProvider<AlarmSoundCubit>(
        create: (_) => AlarmSoundCubit(),
        child: BlocBuilder<AlarmSettingsCubit, AlarmSettings>(
          builder: (context, state) {
            final widgets = [
              AlarmSelector(
                key: TestKey.nonCheckableAlarmSelector,
                heading: t.nonCheckableActivities,
                icon: AbiliaIcons.handiUncheck,
                sound: state.nonCheckableSound,
                onChanged: (sound) => context
                    .read<AlarmSettingsCubit>()
                    .changeAlarmSettings(
                        state.copyWith(nonCheckableSound: sound)),
              ),
              AlarmSelector(
                key: TestKey.checkableAlarmSelector,
                heading: t.checkableActivities,
                icon: AbiliaIcons.handiCheck,
                sound: state.checkableSound,
                onChanged: (sound) => context
                    .read<AlarmSettingsCubit>()
                    .changeAlarmSettings(state.copyWith(checkableSound: sound)),
              ),
              AlarmSelector(
                key: TestKey.reminderAlarmSelector,
                heading: t.reminders,
                icon: AbiliaIcons.handiReminder,
                sound: state.reminderSound,
                noSoundOption: true,
                onChanged: (sound) => context
                    .read<AlarmSettingsCubit>()
                    .changeAlarmSettings(state.copyWith(reminderSound: sound)),
              ),
              SwitchField(
                key: TestKey.vibrateAtReminderSelector,
                value: state.vibrateAtReminder,
                onChanged: (v) => context
                    .read<AlarmSettingsCubit>()
                    .changeAlarmSettings(state.copyWith(vibrateAtReminder: v)),
                child: Text(t.vibrationOnReminder),
              ),
              AlarmDurationSelector(
                key: TestKey.alarmDurationSelector,
                duration: state.alarmDuration,
              ),
            ];
            return Scaffold(
              appBar: AbiliaAppBar(
                title: Translator.of(context).translate.alarmSettings,
                iconData: AbiliaIcons.handiAlarmVibration,
              ),
              body: ListView.separated(
                padding: EdgeInsets.fromLTRB(12.0.s, 20.0.s, 16.0.s, 20.0.s),
                itemBuilder: (context, i) => widgets[i],
                itemCount: widgets.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.0.s),
              ),
              bottomNavigationBar: BottomNavigation(
                backNavigationWidget: CancelButton(),
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
