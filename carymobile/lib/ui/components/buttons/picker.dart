import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:flutter/material.dart';

abstract class PickerButton extends FilledButton {
  final String? leadingText;
  final Widget? leading, trailing;

  PickerButton({
    required super.onPressed,
    required super.style,
    required this.leading,
    required this.leadingText,
    required this.trailing,
    super.key,
  }) : super(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (leading != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: leading,
                    ),
                  if (leadingText != null) Text(leadingText),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    if (trailing != null)
                      Flexible(
                        fit: FlexFit.tight,
                        child: trailing,
                      ) else const Spacer(),
                    const Icon(AbiliaIcons.navigationNext),
                  ] ,
                ),
              ),
            ],
          ),
        );
}

class PickerButtonWhite extends PickerButton {
  PickerButtonWhite({
    required super.onPressed,
    super.leading,
    super.leadingText,
    super.trailing,
    super.key,
  }) : super(style: whiteActionCaryMobileButtonStyle);
}
