import 'package:memoplanner/ui/all.dart';

class IconAndTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final ButtonStyle style;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final double? iconSize;

  const IconAndTextButton({
    required this.text,
    required this.icon,
    required this.style,
    this.onPressed,
    this.padding,
    this.iconSize,
    super.key,
  });

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
              Icon(icon, size: iconSize ?? layout.icon.button),
              SizedBox(width: layout.iconTextButton.iconTextSpacing),
              Flexible(
                child: Text(
                  text,
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
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
    super.key,
  });

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
    super.key,
  });

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
    super.key,
  });

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: textButtonStyleDarkGrey,
      );
}

class LightGreyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;

  const LightGreyButton({
    required this.text,
    required this.icon,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: iconTextButtonStyleLightGrey,
      );
}

class RedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;

  const RedButton({
    required this.text,
    required this.icon,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) => IconAndTextButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        style: iconTextButtonStyleRed,
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
    super.key,
  });

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

  const NextButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) => Tts.data(
        data: Lt.of(context).next,
        child: TextButton(
          style: iconTextButtonStyleNext,
          onPressed: onPressed,
          child: Padding(
            padding: layout.nextButton.padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Lt.of(context).next),
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
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      icon: AbiliaIcons.ok,
      text: Lt.of(context).ok,
      onPressed: onPressed,
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LightButton(
      text: Lt.of(context).previous,
      icon: AbiliaIcons.navigationPrevious,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LightButton(
      text: Lt.of(context).cancel,
      icon: AbiliaIcons.closeProgram,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LightButton(
      text: Lt.of(context).back,
      icon: AbiliaIcons.navigationPrevious,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class CloseButton extends StatelessWidget {
  const CloseButton({
    super.key,
    this.onPressed,
    this.style,
  });
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return IconAndTextButton(
      icon: AbiliaIcons.closeProgram,
      text: Lt.of(context).close,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
      style: style ?? iconTextButtonStyleLight,
    );
  }
}

class YesButton extends StatelessWidget {
  final Function()? onPressed;
  const YesButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      text: Lt.of(context).yes,
      icon: AbiliaIcons.ok,
      onPressed: () async => onPressed != null
          ? onPressed?.call()
          : Navigator.of(context).maybePop(true),
    );
  }
}

class NoButton extends StatelessWidget {
  final Function()? onPressed;
  const NoButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return LightButton(
      text: Lt.of(context).no,
      icon: AbiliaIcons.closeProgram,
      onPressed: () async => onPressed != null
          ? onPressed?.call()
          : Navigator.of(context).maybePop(false),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SaveButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      text: Lt.of(context).save,
      icon: AbiliaIcons.ok,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}

class StartButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const StartButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      text: Lt.of(context).start,
      icon: AbiliaIcons.ok,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }
}
