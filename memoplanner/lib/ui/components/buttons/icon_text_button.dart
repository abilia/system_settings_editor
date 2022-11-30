import 'package:memoplanner/ui/all.dart';

class IconAndTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final ButtonStyle style;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;

  const IconAndTextButton({
    required this.text,
    required this.icon,
    required this.style,
    this.onPressed,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts.data(
      data: text,
      child: TextButton(
        style: style,
        onPressed: onPressed,
        child: Padding(
          padding: padding ?? layout.iconTextButton.padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: layout.icon.button),
              SizedBox(width: layout.iconTextButton.iconTextSpacing),
              Text(text),
            ],
          ),
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
        style: iconTextButtonStyleLight,
      );
}

class IconAndTextButtonDark extends StatelessWidget {
  const IconAndTextButtonDark({
    required this.icon,
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: actionButtonStyleDarkLarge,
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

class GreyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;

  const GreyButton({
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
        style: iconTextButtonStyleGray,
      );
}

class GreenButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;

  const GreenButton({
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
          style: iconTextButtonStyleNext,
          onPressed: onPressed,
          child: Padding(
            padding: layout.nextButton.padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Translator.of(context).translate.next),
                IconTheme(
                  data: lightIconThemeData,
                  child: const Icon(AbiliaIcons.navigationNext),
                ),
              ],
            ),
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
  const CloseButton({
    Key? key,
    this.onPressed,
    this.style,
  }) : super(key: key);
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return IconAndTextButton(
      icon: AbiliaIcons.closeProgram,
      text: Translator.of(context).translate.close,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
      style: style ?? iconTextButtonStyleLight,
    );
  }
}

class YesButton extends StatelessWidget {
  final Function()? onPressed;
  const YesButton({this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      text: Translator.of(context).translate.yes,
      icon: AbiliaIcons.ok,
      onPressed: () => onPressed != null
          ? onPressed?.call()
          : Navigator.of(context).maybePop(true),
    );
  }
}

class NoButton extends StatelessWidget {
  final Function()? onPressed;
  const NoButton({this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LightButton(
      text: Translator.of(context).translate.no,
      icon: AbiliaIcons.closeProgram,
      onPressed: () => onPressed != null
          ? onPressed?.call()
          : Navigator.of(context).maybePop(false),
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

class StartButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const StartButton({this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      text: Translator.of(context).translate.start,
      icon: AbiliaIcons.ok,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}
