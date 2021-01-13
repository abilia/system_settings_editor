import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class SmallDialog extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget forwardNavigationWidget;
  final Widget heading;
  final Widget body;
  const SmallDialog({
    Key key,
    this.heading,
    this.body,
    @required this.backNavigationWidget,
    this.forwardNavigationWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 68,
                  color: AbiliaColors.black80,
                  child: Center(child: heading),
                ),
                Container(
                  color: AbiliaColors.white110,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 64,
                  ),
                  child: Center(
                    child: DefaultTextStyle(
                      style: abiliaTextTheme.bodyText1,
                      child: body,
                    ),
                  ),
                ),
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
        backNavigationWidget: GreyButton(
          text: Translator.of(context).translate.back,
          icon: AbiliaIcons.navigation_previous,
          onPressed: Navigator.of(context).maybePop,
        ),
      );
}
