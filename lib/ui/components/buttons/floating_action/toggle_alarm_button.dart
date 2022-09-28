import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ToggleAlarmButton extends StatelessWidget {
  const ToggleAlarmButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          current.settings.alarm.disabledUntilEpoch !=
          previous.settings.alarm.disabledUntilEpoch,
      builder: (context, settingsState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) => Material(
          color: Colors.transparent,
          elevation: 3,
          shadowColor: AbiliaColors.black,
          borderRadius: borderRadius,
          child: now.isBefore(settingsState.settings.alarm.disabledUntilDate)
              ? const ToggleAlarmButtonActive()
              : ToggleAlarmButtonInactive(now: now),
        ),
      ),
    );
  }
}

class ToggleAlarmButtonActive extends StatelessWidget {
  const ToggleAlarmButtonActive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconActionButton(
      style: actionButtonStyleRed,
      onPressed: () => context.read<GenericCubit>().genericUpdated(
        [
          MemoplannerSettingData.fromData(
            data: 0,
            identifier: AlarmSettings.alarmsDisabledUntilKey,
          ),
        ],
      ),
      ttsData: Translator.of(context).translate.disableAlarms,
      child: const Icon(AbiliaIcons.handiNoAlarmVibration),
    );
  }
}

class ToggleAlarmButtonInactive extends StatelessWidget {
  const ToggleAlarmButtonInactive({
    required this.now,
    Key? key,
  }) : super(key: key);
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return IconActionButtonBlack(
      onPressed: () {
        showViewDialog(
          context: context,
          builder: (context) => WarningDialog(
            text: Translator.of(context).translate.alertAlarmsDisabled,
          ),
        );
        context.read<GenericCubit>().genericUpdated(
          [
            MemoplannerSettingData.fromData(
              data: now.onlyDays().nextDay().millisecondsSinceEpoch,
              identifier: AlarmSettings.alarmsDisabledUntilKey,
            ),
          ],
        );
      },
      ttsData: Translator.of(context).translate.disableAlarms,
      child: const Icon(AbiliaIcons.handiAlarmVibration),
    );
  }
}
