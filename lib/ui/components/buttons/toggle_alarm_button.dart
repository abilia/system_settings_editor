import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/settings/settings_bloc.dart';
import 'package:seagull/ui/all.dart';

class ToggleAlarmButton extends StatelessWidget {
  const ToggleAlarmButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
          current.alarmsDisabled != previous.alarmsDisabled,
      builder: (context, settingsState) => Padding(
        padding: EdgeInsets.fromLTRB(16.s, 0.s, 16.s, 16.s),
        child: Material(
          elevation: 3,
          shadowColor: AbiliaColors.black,
          borderRadius: borderRadius,
          child: ActionButton(
            style: settingsState.alarmsDisabled
                ? actionButtonStyleRed
                : actionButtonStyleBlack,
            onPressed: () {
              if (!settingsState.alarmsDisabled) {
                showViewDialog(
                  context: context,
                  builder: (context) => InfoDialog(
                    title: Translator.of(context).translate.warning,
                    text: Translator.of(context).translate.alertAlarmsDisabled,
                  ),
                );
              }
              context
                  .read<SettingsBloc>()
                  .add(AlarmsDisabledUpdated(!settingsState.alarmsDisabled));
            },
            child: Icon(
              settingsState.alarmsDisabled
                  ? AbiliaIcons.handi_no_alarm_vibration
                  : AbiliaIcons.handi_alarm_vibration,
            ),
          ),
        ),
      ),
    );
  }
}
