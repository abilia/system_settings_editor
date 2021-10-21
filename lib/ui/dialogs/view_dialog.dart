import 'package:flutter/material.dart';

import 'package:seagull/ui/all.dart';

class ViewDialog extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;
  final Widget? heading;
  final Widget body;
  final EdgeInsets? bodyPadding;
  final bool expanded;
  static final horizontalPadding = 20.s;
  const ViewDialog({
    Key? key,
    this.heading,
    required this.body,
    this.expanded = false,
    required this.backNavigationWidget,
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
          style: Theme.of(context).textTheme.bodyText1 ?? bodyText1,
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
                    height: AbiliaAppBar.height,
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
  final Widget? backNavigationWidget;

  const ErrorDialog({
    Key? key,
    required this.text,
    this.backNavigationWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ViewDialog(
        heading: AppBarHeading(
          text: Translator.of(context).translate.error,
          iconData: AbiliaIcons.irError,
        ),
        body: Tts(child: Text(text)),
        backNavigationWidget: backNavigationWidget ?? PreviousButton(),
      );
}

class YesNoDialog extends StatelessWidget {
  final String text;
  final String heading;
  final IconData? headingIcon;
  const YesNoDialog({
    Key? key,
    required this.text,
    required this.heading,
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
      backNavigationWidget: NoButton(),
      forwardNavigationWidget: YesButton(),
    );
  }
}

class WarningDialog extends StatelessWidget {
  final String text;
  const WarningDialog({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: AppBarHeading(
        text: Translator.of(context).translate.warning,
        iconData: AbiliaIcons.gewaRadioError,
      ),
      body: Tts(child: Text(text)),
      forwardNavigationWidget: OkButton(
        onPressed: () => Navigator.of(context).maybePop(true),
      ),
      backNavigationWidget: PreviousButton(),
    );
  }
}
