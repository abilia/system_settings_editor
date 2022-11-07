import 'package:memoplanner/ui/all.dart';

class IconActionButton extends StatelessWidget {
  const IconActionButton({
    required this.child,
    Key? key,
    this.onPressed,
    this.style,
    this.ttsData,
  }) : super(key: key);

  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final Widget child;
  final String? ttsData;

  @override
  Widget build(BuildContext context) {
    final textButton = TextButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
    if (ttsData != null) {
      return Tts.data(data: ttsData, child: textButton);
    }
    return textButton;
  }
}

class IconActionButtonLight extends StatelessWidget {
  const IconActionButtonLight({
    required this.child,
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconActionButton(
        onPressed: onPressed,
        style: actionButtonStyleLight,
        child: child,
      );
}

class IconActionButtonDark extends StatelessWidget {
  const IconActionButtonDark({
    required this.child,
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconActionButton(
        onPressed: onPressed,
        style: actionButtonStyleDark,
        child: child,
      );
}

class IconActionButtonBlack extends StatelessWidget {
  const IconActionButtonBlack({
    required this.child,
    this.onPressed,
    this.ttsData,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;
  final String? ttsData;

  @override
  Widget build(BuildContext context) => IconActionButton(
        onPressed: onPressed,
        style: actionButtonStyleBlack,
        ttsData: ttsData,
        child: child,
      );
}
