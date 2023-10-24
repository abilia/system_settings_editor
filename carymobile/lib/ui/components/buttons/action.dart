import 'package:carymessenger/ui/themes/theme.dart';
import 'package:flutter/material.dart';

abstract class ActionButton extends FilledButton {
  final Widget? leading;
  final String? text;

  ActionButton({
    required super.onPressed,
    required super.onLongPress,
    required super.style,
    required this.leading,
    required this.text,
    super.key,
  }) : super(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: leading,
                ),
              if (text != null) Text(text),
            ],
          ),
        );
}

class ActionButtonBlack extends ActionButton {
  ActionButtonBlack({
    required super.onPressed,
    super.onLongPress,
    super.key,
    super.leading,
    super.text,
  }) : super(style: null);
}

class ActionButtonGreen extends ActionButton {
  ActionButtonGreen({
    required super.onPressed,
    super.onLongPress,
    super.leading,
    super.text,
    super.key,
  }) : super(style: greenActionCaryMobileButtonStyle);
}

class ActionButtonWhite extends ActionButton {
  ActionButtonWhite({
    required super.onPressed,
    super.onLongPress,
    super.leading,
    super.text,
    super.key,
  }) : super(style: whiteActionCaryMobileButtonStyle);
}

class ActionButtonRed extends ActionButton {
  ActionButtonRed({
    required super.onPressed,
    super.onLongPress,
    super.leading,
    super.text,
    super.key,
  }) : super(style: redActionCaryMobileButtonStyle);
}
