import 'package:flutter/widgets.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class GoToNowButton extends StatelessWidget {
  const GoToNowButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ScrollPositionBloc, ScrollPositionState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, scrollState) => AnimatedSwitcher(
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          duration: Duration(milliseconds: 300),
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
                        context.read<ScrollPositionBloc>().add(GoToNow()),
                    style: actionIconTextButtonStyleRed,
                  ),
                )
              : null,
        ),
      );
}

class GoToCurrentWeekButton extends StatelessWidget {
  const GoToCurrentWeekButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      style: actionButtonStyleRed,
      onPressed: () => context.read<WeekCalendarBloc>().add(GoToCurrentWeek()),
      child: Icon(
        AbiliaIcons.reset,
      ),
    );
  }
}
