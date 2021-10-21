import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class FloatingActions extends StatelessWidget {
  const FloatingActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return BlocBuilder<PermissionBloc, PermissionState>(
      buildWhen: (old, fresh) =>
          old.notificationDenied != fresh.notificationDenied,
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (tabController != null)
              _ToggleAlarmAndEyeButtons(tabController: tabController)
            else if (context
                .read<MemoplannerSettingBloc>()
                .state
                .displayAlarmButton)
              const ToggleAlarmButton(),
            if (state.notificationDenied)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12.s,
                    right: 24.s,
                    bottom: 12.s,
                  ),
                  child: ErrorMessage(
                    text: Text(
                      Translator.of(context).translate.notificationsWarningText,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ToggleAlarmAndEyeButtons extends StatelessWidget {
  final TabController tabController;

  const _ToggleAlarmAndEyeButtons({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      buildWhen: (previous, current) =>
          previous.displayEyeButton != current.displayEyeButton ||
          previous.displayAlarmButton != current.displayAlarmButton ||
          previous.calendarCount != current.calendarCount,
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (state.displayAlarmButton) const ToggleAlarmButton(),
            if (state.displayEyeButton)
              if (tabController.index == 0)
                Padding(
                  padding: EdgeInsets.only(top: 8.s),
                  child: const EyeButtonDay(),
                )
              else if (state.displayMonthCalendar &&
                  tabController.index == tabController.length - 1)
                Padding(
                  padding: EdgeInsets.only(top: 8.s),
                  child: const EyeButtonMonth(),
                ),
          ],
        );
      },
    );
  }
}
