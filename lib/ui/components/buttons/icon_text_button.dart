import 'package:seagull/ui/all.dart';

class IconAndTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final ThemeData theme;
  final VoidCallback onPressed;

  const IconAndTextButton({
    Key key,
    @required this.text,
    @required this.icon,
    @required this.theme,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts(
      data: text,
      child: FlatButton.icon(
        minWidth: 172.0,
        height: 64,
        icon: IconTheme(
          data: theme.iconTheme,
          child: Icon(icon),
        ),
        label: Text(
          text,
          style: theme.textTheme.button,
        ),
        color: theme.buttonColor,
        onPressed: onPressed,
        disabledColor: theme.disabledColor,
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
        theme: greyButtonTheme,
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
        theme: greenButtonTheme,
      );
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) => Tts(
        data: Translator.of(context).translate.next,
        child: FlatButton(
          minWidth: 172.0,
          height: 64,
          child: Row(
            children: [
              const Spacer(flex: 63),
              Text(
                Translator.of(context).translate.next,
                style: greenButtonTheme.textTheme.button,
              ),
              IconTheme(
                data: greenButtonTheme.iconTheme,
                child: Icon(AbiliaIcons.navigation_next),
              ),
              const Spacer(flex: 47),
            ],
          ),
          color: greenButtonTheme.buttonColor,
          disabledColor: greenButtonTheme.disabledColor,
          onPressed: onPressed,
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
