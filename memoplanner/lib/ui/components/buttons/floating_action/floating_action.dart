import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class FloatingActions extends StatelessWidget {
  final bool useBottomPadding;

  const FloatingActions({
    this.useBottomPadding = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.maybeOf(context);
    final settings = context.watch<MemoplannerSettingsBloc>().state;
    return BlocBuilder<PermissionCubit, PermissionState>(
      buildWhen: (old, fresh) =>
          old.notificationDenied != fresh.notificationDenied,
      builder: (context, permission) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (tabController != null)
              _ToggleAlarmAndEyeButtons(
                tabController: tabController,
                useBottomPadding: useBottomPadding,
              ),
            if (permission.notificationDenied)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: layout.formPadding.largeHorizontalItemDistance,
                    right: layout.formPadding.largeHorizontalItemDistance * 2,
                  ),
                  child: ErrorMessage(
                    text: Text(
                      Translator.of(context).translate.notificationsWarningText,
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
            if (tabController != null &&
                tabController.index == settings.functions.display.menuTabIndex)
              const AboutButton(),
          ],
        );
      },
    );
  }
}

class _ToggleAlarmAndEyeButtons extends StatelessWidget {
  final TabController tabController;
  final bool useBottomPadding;

  const _ToggleAlarmAndEyeButtons({
    required this.tabController,
    required this.useBottomPadding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayEyeButton = context
        .select((DayCalendarViewCubit bloc) => bloc.state.displayEyeButton);
    final showAlarmOnOffSwitch = context.select(
        (MemoplannerSettingsBloc bloc) =>
            bloc.state.alarm.showAlarmOnOffSwitch);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showAlarmOnOffSwitch) const ToggleAlarmButton(),
        if (displayEyeButton)
          if (tabController.index == 0)
            Padding(
              padding: EdgeInsets.only(
                top: layout.formPadding.verticalItemDistance,
              ),
              child: const EyeButtonDay(),
            ),
        if (useBottomPadding)
          const IconActionButtonLight(child: SizedBox.shrink()),
      ],
    );
  }
}
