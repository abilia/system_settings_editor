import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FloatingActions extends StatelessWidget {
  final bool useBottomPadding;
  final bool displayAboutButton;
  final bool displayEyeButton;

  const FloatingActions({
    this.useBottomPadding = false,
    this.displayAboutButton = false,
    this.displayEyeButton = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionCubit, PermissionState>(
      buildWhen: (old, fresh) =>
          old.notificationDenied != fresh.notificationDenied,
      builder: (context, permission) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _ToggleAlarmAndEyeButtons(
              useBottomPadding: useBottomPadding,
              displayEyeButton: displayEyeButton,
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
                      Lt.of(context).notificationsWarningText,
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
            if (displayAboutButton) const AboutButton(),
          ],
        );
      },
    );
  }
}

class _ToggleAlarmAndEyeButtons extends StatelessWidget {
  final bool useBottomPadding;
  final bool displayEyeButton;

  const _ToggleAlarmAndEyeButtons({
    required this.useBottomPadding,
    required this.displayEyeButton,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showAlarmOnOffSwitch = context.select(
        (MemoplannerSettingsBloc bloc) =>
            bloc.state.alarm.showAlarmOnOffSwitch);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showAlarmOnOffSwitch) const ToggleAlarmButton(),
        AnimatedSize(
          duration: 250.milliseconds(),
          child: displayEyeButton || useBottomPadding
              ? Padding(
                  padding: EdgeInsets.only(
                    top: layout.formPadding.verticalItemDistance,
                  ),
                  child: displayEyeButton
                      ? const EyeButtonDay()
                      : const IconActionButtonLight(
                          child: SizedBox.shrink(),
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
