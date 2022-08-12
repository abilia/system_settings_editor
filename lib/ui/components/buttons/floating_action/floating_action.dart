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
                  )
                else
                  const Spacer(),
                if (tabController != null && tabController.index == 3)
                  const _AboutButton(),
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

class _AboutButton extends StatelessWidget {
  const _AboutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return InfoButton(
      onTap: () {
        showViewDialog(
            context: context,
            builder: (_) {
              return ViewDialog(
                heading: AppBarHeading(
                  text: translate.about,
                  iconData: AbiliaIcons.information,
                ),
                backNavigationWidget: const CloseButton(),
                body: const AboutContent(updateButton: false),
                bodyPadding: EdgeInsets.zero,
                expanded: true,
              );
            });
      },
    ).pad(layout.menuPage.aboutButtonPadding);
  }
}
