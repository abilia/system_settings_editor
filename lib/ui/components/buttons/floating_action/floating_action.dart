import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class FloatingActions extends StatelessWidget {
  const FloatingActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return BlocBuilder<PermissionCubit, PermissionState>(
      buildWhen: (old, fresh) =>
          old.notificationDenied != fresh.notificationDenied,
      builder: (context, permission) {
        return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          buildWhen: (previous, current) =>
              previous.displayAlarmButton != current.displayAlarmButton ||
              previous.alarm.showAlarmOnOffSwitch !=
                  current.alarm.showAlarmOnOffSwitch,
          builder: (context, settings) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (tabController != null)
                  _ToggleAlarmAndEyeButtons(tabController: tabController)
                else if (settings.alarm.showAlarmOnOffSwitch)
                  const ToggleAlarmButton(),
                if (permission.notificationDenied)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: layout.formPadding.largeHorizontalItemDistance,
                        right:
                            layout.formPadding.largeHorizontalItemDistance * 2,
                      ),
                      child: ErrorMessage(
                        text: Text(
                          Translator.of(context)
                              .translate
                              .notificationsWarningText,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ToggleAlarmAndEyeButtons extends StatelessWidget {
  final TabController tabController;

  const _ToggleAlarmAndEyeButtons({
    required this.tabController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.displayEyeButton != current.displayEyeButton ||
          previous.displayAlarmButton != current.displayAlarmButton ||
          previous.calendarCount != current.calendarCount ||
          previous.monthCalendarTabIndex != current.monthCalendarTabIndex ||
          previous.alarm.showAlarmOnOffSwitch !=
              current.alarm.showAlarmOnOffSwitch,
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (state.alarm.showAlarmOnOffSwitch) const ToggleAlarmButton(),
            if (state.displayEyeButton)
              if (tabController.index == 0)
                Padding(
                  padding: EdgeInsets.only(
                    top: layout.formPadding.verticalItemDistance,
                  ),
                  child: const EyeButtonDay(),
                ),
          ],
        );
      },
    );
  }
}
