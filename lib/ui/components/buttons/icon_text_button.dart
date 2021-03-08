import 'package:seagull/ui/all.dart';

class IconAndTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final ButtonStyle style;
  final VoidCallback onPressed;

  const IconAndTextButton({
    Key key,
    @required this.text,
    @required this.icon,
    @required this.style,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts(
      data: text,
      child: IconTheme(
        data: lightIconThemeData,
        child: TextButton.icon(
          style: style,
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(text),
        ),
      ),
    );
  }
}

class GreyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const GreyButton({
    Key key,
    @required this.text,
    @required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: iconTextButtonStyleDarkGrey,
      );
}

class GreenButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const GreenButton({
    Key key,
    @required this.text,
    @required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: iconTextButtonStyleGreen,
      );
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) => Tts(
        data: Translator.of(context).translate.next,
        child: TextButton(
          style: iconTextButtonStyleGreen,
          onPressed: onPressed,
          child: Row(
            children: [
              const Spacer(flex: 63),
              Text(Translator.of(context).translate.next),
              Icon(AbiliaIcons.navigation_next),
              const Spacer(flex: 47),
            ],
          ),
        ),
      );
}

class OkButton extends StatelessWidget {
  final VoidCallback onPressed;
  const OkButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      icon: AbiliaIcons.ok,
      text: Translator.of(context).translate.ok,
      onPressed: onPressed,
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreyButton(
      text: Translator.of(context).translate.back,
      icon: AbiliaIcons.navigation_previous,
      onPressed: Navigator.of(context).maybePop,
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({Key key, this.onPressed}) : super(key: key);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GreyButton(
      text: Translator.of(context).translate.cancel,
      icon: AbiliaIcons.close_program,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class CloseButton extends StatelessWidget {
  const CloseButton({Key key, this.onPressed}) : super(key: key);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GreyButton(
      icon: AbiliaIcons.close_program,
      text: Translator.of(context).translate.close,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({Key key, this.onPressed}) : super(key: key);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GreyButton(
      icon: AbiliaIcons.navigation_previous,
      text: Translator.of(context).translate.back,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}
