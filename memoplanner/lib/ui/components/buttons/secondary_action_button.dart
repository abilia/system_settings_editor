import 'package:memoplanner/ui/all.dart';

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    required this.style,
    required this.child,
    this.onPressed,
    super.key,
  });

  final ButtonStyle style;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => IconTheme(
        data: Theme.of(context).iconTheme.copyWith(size: layout.icon.small),
        child: IconActionButton(
          onPressed: onPressed,
          style: style,
          child: child,
        ),
      );
}

class SecondaryActionButtonLight extends StatelessWidget {
  const SecondaryActionButtonLight({
    required this.child,
    this.onPressed,
    super.key,
  });

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
    required this.child,
    this.onPressed,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SecondaryActionButton(
        onPressed: onPressed,
        style: secondaryActionButtonStyleDark,
        child: child,
      );
}
