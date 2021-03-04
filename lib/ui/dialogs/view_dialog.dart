import 'package:flutter/material.dart';

import 'package:seagull/ui/all.dart';

class ViewDialog extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget forwardNavigationWidget;
  final Widget heading;
  final Widget body;
  final EdgeInsets bodyPadding;
  final bool expanded;
  static final horizontalPadding = 20.s;
  const ViewDialog({
    Key key,
    this.heading,
    this.body,
    this.expanded = false,
    @required this.backNavigationWidget,
    this.forwardNavigationWidget,
    this.bodyPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyContainer = Container(
      color: AbiliaColors.white110,
      padding: bodyPadding ??
          EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 64.s,
          ),
      child: Center(
        child: DefaultTextStyle(
          style: abiliaTextTheme.bodyText1,
          textAlign: TextAlign.center,
          child: body,
        ),
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0.s, vertical: 48.s),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (heading != null)
                  Container(
                    height: 68.s,
                    color: AbiliaColors.black80,
                    child: Center(child: heading),
                  ),
                expanded
                    ? Flexible(
                        child: bodyContainer,
                      )
                    : bodyContainer,
                BottomNavigation(
                  useSafeArea: false,
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
  Widget build(BuildContext context) => ViewDialog(
        heading: AppBarHeading(
          text: Translator.of(context).translate.error,
          iconData: AbiliaIcons.ir_error,
        ),
        body: Tts(child: Text(text)),
        backNavigationWidget: PreviousButton(),
      );
}

class YesNoDialog extends StatelessWidget {
  final String text;
  final String heading;
  final IconData headingIcon;
  const YesNoDialog({
    Key key,
    this.text,
    this.heading,
    this.headingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: AppBarHeading(
        text: heading,
        iconData: headingIcon,
      ),
      body: Tts(child: Text(text)),
      backNavigationWidget: GreyButton(
        key: TestKey.noButton,
        text: Translator.of(context).translate.no,
        icon: AbiliaIcons.close_program,
        onPressed: () => Navigator.of(context).maybePop(false),
      ),
      forwardNavigationWidget: GreenButton(
        key: TestKey.yesButton,
        text: Translator.of(context).translate.yes,
        icon: AbiliaIcons.ok,
        onPressed: () => Navigator.of(context).maybePop(true),
      ),
    );
  }
}
