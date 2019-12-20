import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class GoToNowButton extends StatelessWidget {
  final Function onPressed;

  const GoToNowButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ScrollPositionBloc, ScrollPositionState>(
        builder: (context, scrollState) =>
            scrollState is WrongDay || scrollState is OutOfView
                ? ActionButton(
                    key: TestKey.goToNowButton,
                    child: Icon(AbiliaIcons.reset),
                    onPressed: onPressed,
                    themeData: nowButtonTheme(context))
                : const SizedBox(width: 48),
      );
}
