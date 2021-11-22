import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
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

class ActionButtonLight extends StatelessWidget {
  const ActionButtonLight({
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ActionButton(
        onPressed: onPressed,
        style: actionButtonStyleLight,
        child: child,
      );
}

class ActionButtonDark extends StatelessWidget {
  const ActionButtonDark({
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ActionButton(
        onPressed: onPressed,
        style: actionButtonStyleDark,
        child: child,
      );
}

class ActionButtonBlack extends StatelessWidget {
  const ActionButtonBlack({
    Key? key,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ActionButton(
        onPressed: onPressed,
        style: actionButtonStyleBlack,
        child: child,
      );
}

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
        data: Theme.of(context).iconTheme.copyWith(size: Lay.out.iconSize.small),
        child: ActionButton(
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
