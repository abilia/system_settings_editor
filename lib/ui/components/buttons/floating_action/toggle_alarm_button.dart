import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/datetime.dart';

class ToggleAlarmButton extends StatelessWidget {
  const ToggleAlarmButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          current.alarm.disabledUntilEpoch != current.alarm.disabledUntilEpoch,
      builder: (context, settingsState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) => Material(
          color: Colors.transparent,
          elevation: 3,
          shadowColor: AbiliaColors.black,
          borderRadius: borderRadius,
          child: now.isBefore(settingsState.alarm.disabledUntilDate)
              ? const _ToggleAlarmButtonActive()
              : _ToggleAlarmButtonInactive(now: now),
        ),
      ),
    );
  }
}

class _ToggleAlarmButtonActive extends StatelessWidget {
  const _ToggleAlarmButtonActive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      style: actionButtonStyleRed,
      onPressed: () => context.read<GenericBloc>().add(
            GenericUpdated(
              [
                MemoplannerSettingData.fromData(
                  data: 0,
                  identifier: AlarmSettings.alarmsDisabledUntilKey,
                ),
              ],
            ),
          ),
      child: Icon(AbiliaIcons.handi_no_alarm_vibration),
    );
  }
}

class _ToggleAlarmButtonInactive extends StatelessWidget {
  const _ToggleAlarmButtonInactive({Key? key, required this.now})
      : super(key: key);
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return ActionButtonBlack(
      onPressed: () {
        showViewDialog(
          context: context,
          builder: (context) => WarningDialog(
            text: Translator.of(context).translate.alertAlarmsDisabled,
          ),
        );
        context.read<GenericBloc>().add(
              GenericUpdated(
                [
                  MemoplannerSettingData.fromData(
                    data: now.onlyDays().nextDay().millisecondsSinceEpoch,
                    identifier: AlarmSettings.alarmsDisabledUntilKey,
                  ),
                ],
              ),
            );
      },
      child: Icon(AbiliaIcons.handi_alarm_vibration),
    );
  }
}
