import 'package:seagull/ui/all.dart';

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    Key? key,
    this.onPressed,
    required this.style,
    required this.child,
  }) : super(key: key);

  final ButtonStyle style;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => IconTheme(
        data: Theme.of(context).iconTheme.copyWith(size: layout.iconSize.small),
        child: IconActionButton(
          onPressed: onPressed,
          style: style,
          child: child,
        ),
      );
}

class SecondaryActionButtonLight extends StatelessWidget {
  const SecondaryActionButtonLight({
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SecondaryActionButton(
        onPressed: onPressed,
        style: secondaryActionButtonStyleLight,
        child: child,
      );
}

class SecondaryActionButtonDark extends StatelessWidget {
  const SecondaryActionButtonDark({
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SecondaryActionButton(
        onPressed: onPressed,
        style: secondaryActionButtonStyleDark,
        child: child,
      );
}
