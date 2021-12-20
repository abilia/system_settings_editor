import 'package:seagull/ui/all.dart';

class IconActionButton extends StatelessWidget {
  const IconActionButton({
    Key? key,
    this.onPressed,
    this.style,
    required this.child,
  }) : super(key: key);

  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
}

class IconActionButtonLight extends StatelessWidget {
  const IconActionButtonLight({
    Key? key,
    this.onPressed,
    required this.child,
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
    Key? key,
    this.onPressed,
    required this.child,
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
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconActionButton(
        onPressed: onPressed,
        style: actionButtonStyleBlack,
        child: child,
      );
}
