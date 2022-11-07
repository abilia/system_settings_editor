import 'package:memoplanner/ui/all.dart';

class ViewDialog extends StatelessWidget {
  final Widget backNavigationWidget;
  final Widget? forwardNavigationWidget;
  final Widget? heading;
  final Widget body;
  final EdgeInsets? bodyPadding;
  final bool expanded;

  const ViewDialog({
    required this.body,
    required this.backNavigationWidget,
    this.heading,
    this.expanded = false,
    this.forwardNavigationWidget,
    this.bodyPadding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyContainer = Container(
      color: AbiliaColors.white110,
      padding: bodyPadding ?? layout.templates.l2,
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
          padding: layout.templates.s5,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (heading != null)
                  Container(
                    height: layout.appBar.smallHeight,
                    color: AbiliaColors.black80,
                    child: Center(child: heading),
                  ),
                if (expanded) Flexible(child: bodyContainer) else bodyContainer,
                BottomNavigation(
                  useVerticalSafeArea: false,
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
    required this.text,
    this.backNavigationWidget,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ViewDialog(
        heading: AppBarHeading(
          text: Translator.of(context).translate.error,
          iconData: AbiliaIcons.irError,
        ),
        body: Tts(child: Text(text)),
        backNavigationWidget: backNavigationWidget ?? const PreviousButton(),
      );
}

class YesNoDialog extends StatelessWidget {
  final String text;
  final String heading;
  final IconData? headingIcon;
  const YesNoDialog({
    required this.text,
    required this.heading,
    this.headingIcon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: AppBarHeading(
        text: heading,
        iconData: headingIcon,
      ),
      body: Tts(child: Text(text)),
      backNavigationWidget: const NoButton(),
      forwardNavigationWidget: const YesButton(),
    );
  }
}

class ConfirmWarningDialog extends StatelessWidget {
  final String text;
  const ConfirmWarningDialog({
    required this.text,
    Key? key,
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
      backNavigationWidget: const PreviousButton(),
    );
  }
}

class WarningDialog extends StatelessWidget {
  final String text;

  const WarningDialog({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: AppBarHeading(
        text: Translator.of(context).translate.warning,
        iconData: AbiliaIcons.irError,
      ),
      body: Tts(child: Text(text)),
      backNavigationWidget: OkButton(onPressed: Navigator.of(context).maybePop),
    );
  }
}
