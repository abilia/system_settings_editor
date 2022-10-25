import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class GoToNowButton extends StatelessWidget {
  const GoToNowButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ScrollPositionCubit, ScrollPositionState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, scrollState) => AnimatedSwitcher(
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          duration: DayCalendar.calendarTransitionDuration,
          child: scrollState is WrongDay || scrollState is OutOfView
              ? Material(
                  color: Colors.transparent,
                  elevation: 3,
                  shadowColor: AbiliaColors.black,
                  borderRadius: borderRadius,
                  child: IconAndTextButton(
                    key: TestKey.goToNowButton,
                    text: Translator.of(context).translate.now,
                    icon: AbiliaIcons.reset,
                    onPressed: () =>
                        context.read<ScrollPositionCubit>().goToNow(),
                    style: actionIconTextButtonStyleRed,
                    padding: EdgeInsets.zero,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      );
}

class GoToCurrentActionButton extends StatelessWidget {
  const GoToCurrentActionButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconActionButton(
      style: actionButtonStyleRedLarge,
      onPressed: onPressed,
      child: const Icon(AbiliaIcons.reset),
    );
  }
}
