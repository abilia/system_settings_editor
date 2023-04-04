import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ToggleAlarmButton extends StatelessWidget {
  const ToggleAlarmButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final disabledUntilDate = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.alarm.disabledUntilDate);
    final now = context.watch<ClockBloc>().state;
    return Material(
      color: Colors.transparent,
      elevation: 3,
      shadowColor: AbiliaColors.black,
      borderRadius: borderRadius,
      child: now.isBefore(disabledUntilDate)
          ? const ToggleAlarmButtonActive()
          : ToggleAlarmButtonInactive(now: now),
    );
  }
}

class ToggleAlarmButtonActive extends StatelessWidget {
  const ToggleAlarmButtonActive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconActionButton(
      style: actionButtonStyleRed,
      onPressed: () async => context.read<GenericCubit>().genericUpdated(
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
      onPressed: () async => Future.wait(
        [
          showViewDialog(
            context: context,
            builder: (context) => WarningDialog(
              text: Translator.of(context).translate.alertAlarmsDisabled,
            ),
            routeSettings: (WarningDialog).routeSetting(
              properties: {'reason': 'Alarms disabled until midnight'},
            ),
          ),
          context.read<GenericCubit>().genericUpdated(
            [
              MemoplannerSettingData.fromData(
                data: now.onlyDays().nextDay().millisecondsSinceEpoch,
                identifier: AlarmSettings.alarmsDisabledUntilKey,
              ),
            ],
          ),
        ],
      ),
      ttsData: Translator.of(context).translate.disableAlarms,
      child: const Icon(AbiliaIcons.handiAlarmVibration),
    );
  }
}
