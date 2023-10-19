import 'package:flutter/material.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/components/spinner.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/buttons/action_button/action_button_themes.dart';

enum ActionButtonType {
  primary,
  secondary,
  tertiary,
  tertiaryNoBorder,
}

class SeagullActionButton extends StatefulWidget {
  final String text;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final ActionButtonType type;
  final ButtonSize size;
  final bool isLoading;

  const SeagullActionButton({
    required this.type,
    required this.text,
    required this.size,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    super.key,
  });

  @override
  State<SeagullActionButton> createState() => _SeagullActionButtonState();
}

class _SeagullActionButtonState extends State<SeagullActionButton> {
  final statesController = MaterialStatesController();
  late SeagullActionButtonTheme _actionButtonTheme;

  @override
  void didChangeDependencies() {
    _actionButtonTheme = _getTheme(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      statesController: statesController,
      style: _actionButtonTheme.buttonStyle,
      onPressed: widget.isLoading && widget.onPressed != null
          ? () {}
          : widget.onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leadingIcon != null) ...[
            if (widget.isLoading) _spinnerIcon() else Icon(widget.leadingIcon),
            SizedBox(width: _actionButtonTheme.iconSpacing),
          ],
          Flexible(
            child: Text(
              widget.text,
              softWrap: true,
              maxLines: 1,
            ),
          ),
          if (widget.trailingIcon != null) ...[
            SizedBox(width: _actionButtonTheme.iconSpacing),
            if (widget.isLoading) _spinnerIcon() else Icon(widget.trailingIcon),
          ],
        ],
      ),
    );
  }

  Widget _spinnerIcon() {
    final color = _actionButtonTheme.buttonStyle.foregroundColor
        ?.resolve(statesController.value);
    return SeagullSpinner(
      size: _actionButtonTheme.spinnerSize,
      color: color,
    );
  }

  SeagullActionButtonTheme _getTheme(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    switch (widget.type) {
      case ActionButtonType.primary:
        switch (widget.size) {
          case ButtonSize.small:
            return abiliaTheme.actionButtons.primarySmall;
          case ButtonSize.medium:
            return abiliaTheme.actionButtons.primaryMedium;
          case ButtonSize.large:
            return abiliaTheme.actionButtons.primaryLarge;
        }
      case ActionButtonType.secondary:
        switch (widget.size) {
          case ButtonSize.small:
            return abiliaTheme.actionButtons.secondarySmall;
          case ButtonSize.medium:
            return abiliaTheme.actionButtons.secondaryMedium;
          case ButtonSize.large:
            return abiliaTheme.actionButtons.secondaryLarge;
        }
      case ActionButtonType.tertiary:
        switch (widget.size) {
          case ButtonSize.small:
            return abiliaTheme.actionButtons.tertiarySmall;
          case ButtonSize.medium:
            return abiliaTheme.actionButtons.tertiaryMedium;
          case ButtonSize.large:
            return abiliaTheme.actionButtons.tertiaryLarge;
        }
      case ActionButtonType.tertiaryNoBorder:
        switch (widget.size) {
          case ButtonSize.small:
            return abiliaTheme.actionButtons.tertiaryNoBorderSmall;
          case ButtonSize.medium:
            return abiliaTheme.actionButtons.tertiaryNoBorderMedium;
          case ButtonSize.large:
            return abiliaTheme.actionButtons.tertiaryNoBorderLarge;
        }
    }
  }
}
