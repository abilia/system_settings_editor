import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class SmallDialog extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget forwardNavigationWidget;
  final Widget heading;
  final Widget body;
  final EdgeInsets bodyPadding;
  final bool expanded;
  const SmallDialog({
    Key key,
    this.heading,
    this.body,
    this.expanded = false,
    @required this.backNavigationWidget,
    this.forwardNavigationWidget,
    this.bodyPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 64,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyContainer = Container(
      color: AbiliaColors.white110,
      padding: bodyPadding,
      child: Center(
        child: DefaultTextStyle(
          style: abiliaTextTheme.bodyText1,
          child: body,
        ),
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 48),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (heading != null)
                  Container(
                    height: 68,
                    color: AbiliaColors.black80,
                    child: Center(child: heading),
                  ),
                expanded
                    ? Flexible(
                        child: bodyContainer,
                      )
                    : bodyContainer,
                BottomNavigation(
                  backNavigationWidget: backNavigationWidget,
                  forwardNavigationWidget: forwardNavigationWidget,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String text;

  const ErrorDialog({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) => SmallDialog(
        heading: AppBarHeading(
          text: Translator.of(context).translate.error,
          iconData: AbiliaIcons.ir_error,
        ),
        body: Tts(child: Text(text)),
        backNavigationWidget: PreviousButton(),
      );
}
