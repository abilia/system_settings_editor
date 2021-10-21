import 'package:seagull/ui/all.dart';

class IconAndTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final ButtonStyle style;
  final VoidCallback? onPressed;

  const IconAndTextButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.style,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts.data(
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

class LightButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;

  const LightButton({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: iconTextButtonStyleLight,
      );
}

class DarkGreyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;

  const DarkGreyButton({
    required this.text,
    required this.icon,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: textButtonStyleDarkGrey,
      );
}

class GreenButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;

  const GreenButton({
    Key? key,
    required this.text,
    required this.icon,
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
  final VoidCallback? onPressed;

  const NextButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) => Tts.data(
        data: Translator.of(context).translate.next,
        child: TextButton(
          style: iconTextButtonStyleGreen,
          onPressed: onPressed,
          child: Row(
            children: [
              const Spacer(flex: 63),
              Text(Translator.of(context).translate.next),
              Icon(
                AbiliaIcons.navigationNext,
                size: buttonIconSize,
              ),
              const Spacer(flex: 47),
            ],
          ),
        ),
      );
}

class OkButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const OkButton({
    Key? key,
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
  const PreviousButton({Key? key, this.onPressed}) : super(key: key);
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LightButton(
      text: Translator.of(context).translate.back,
      icon: AbiliaIcons.navigationPrevious,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({Key? key, this.onPressed}) : super(key: key);
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LightButton(
      text: Translator.of(context).translate.cancel,
      icon: AbiliaIcons.closeProgram,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class CloseButton extends StatelessWidget {
  const CloseButton({Key? key, this.onPressed}) : super(key: key);
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LightButton(
      icon: AbiliaIcons.closeProgram,
      text: Translator.of(context).translate.close,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class YesButton extends StatelessWidget {
  const YesButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GreenButton(
      text: Translator.of(context).translate.yes,
      icon: AbiliaIcons.ok,
      onPressed: () => Navigator.of(context).maybePop(true),
    );
  }
}

class NoButton extends StatelessWidget {
  const NoButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LightButton(
      text: Translator.of(context).translate.no,
      icon: AbiliaIcons.closeProgram,
      onPressed: () => Navigator.of(context).maybePop(false),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const SaveButton({this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      text: Translator.of(context).translate.save,
      icon: AbiliaIcons.ok,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}
