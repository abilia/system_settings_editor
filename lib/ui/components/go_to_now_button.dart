import 'package:flutter/widgets.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/theme.dart';

class GoToNowButton extends StatelessWidget {
  final Function onDayPressed;
  final Function onOtherDayPressed;

  const GoToNowButton(
      {Key key, @required this.onDayPressed, @required this.onOtherDayPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ScrollPositionBloc, ScrollPositionState>(
        builder: (context, scrollState) => scrollState is WrongDay ||
                scrollState is OutOfView
            ? ActionButton(
                key: TestKey.goToNowButton,
                child: Icon(AbiliaIcons.reset),
                onPressed:
                    scrollState is WrongDay ? onOtherDayPressed : onDayPressed,
                themeData: nowButtonTheme(context))
            : const SizedBox(width: 48),
      );
}