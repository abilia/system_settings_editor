import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/generic/generic_bloc.dart';
import 'package:seagull/bloc/generic/memoplannersetting/memoplanner_setting_bloc.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/models/settings/memoplanner_settings.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/datetime.dart';

class ToggleAlarmButton extends StatelessWidget {
  const ToggleAlarmButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) {
        return current.alarmsDisabledUntil
                .compareTo(previous.alarmsDisabledUntil) !=
            0;
      },
      builder: (context, settingsState) => Padding(
        padding: EdgeInsets.fromLTRB(16.s, 0.s, 16.s, 16.s),
        child: Material(
          elevation: 3,
          shadowColor: AbiliaColors.black,
          borderRadius: borderRadius,
          child: ActionButton(
            style: settingsState.alarmsDisabledUntil.isAfter(now)
                ? actionButtonStyleRed
                : actionButtonStyleBlack,
            onPressed: () async {
              if (!settingsState.alarmsDisabledUntil.isAfter(now)) {
                showViewDialog(
                  context: context,
                  builder: (context) => InfoDialog(
                    title: Translator.of(context).translate.warning,
                    text: Translator.of(context).translate.alertAlarmsDisabled,
                  ),
                );
              }
              context.read<GenericBloc>().add(
                    GenericUpdated(
                      [
                        MemoplannerSettingData.fromData(
                          data: settingsState.alarmsDisabledUntil.isAfter(now)
                              ? 0
                              : DateTime.now()
                                  .onlyDays()
                                  .nextDay()
                                  .millisecondsSinceEpoch,
                          identifier:
                              MemoplannerSettings.alarmsDisabledUntilKey,
                        ),
                      ],
                    ),
                  );
            },
            child: Icon(
              settingsState.alarmsDisabledUntil.isAfter(now)
                  ? AbiliaIcons.handi_no_alarm_vibration
                  : AbiliaIcons.handi_alarm_vibration,
            ),
          ),
        ),
      ),
    );
  }
}
