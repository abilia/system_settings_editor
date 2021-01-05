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
        builder: (context, scrollState) =>
            scrollState is WrongDay || scrollState is OutOfView
                ? ActionButton(
                    key: TestKey.goToNowButton,
                    child: Icon(
                      AbiliaIcons.reset,
                    ),
                    onPressed: () =>
                        context.read<ScrollPositionBloc>().add(GoToNow()),
                    themeData: nowButtonTheme,
                  )
                : const SizedBox(width: ActionButton.size),
      );
}
