import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/components/helper_box.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/combo_box/combo_box_themes.dart';
import 'package:ui/utils/sizes.dart';
import 'package:ui/utils/states.dart';

typedef ComboBoxSize = MediumLargeSize;

class SeagullComboBox extends StatefulWidget {
  final String? hintText;
  final String? label;
  final String? message;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final MessageState? messageState;
  final ComboBoxSize size;
  final VoidCallback? onTrailingIconOnTap;

  const SeagullComboBox({
    required this.size,
    this.controller,
    this.hintText,
    this.onChanged,
    this.label,
    this.message,
    this.leadingIcon,
    this.trailingIcon,
    this.textInputAction,
    this.enabled = true,
    this.obscureText = false,
    this.messageState,
    this.onTrailingIconOnTap,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _SeagullComboBoxState();
  }
}

class _SeagullComboBoxState extends State<SeagullComboBox> {
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    final spacings = abiliaTheme.spacings;
    final comboBoxTheme = _getTheme(context);
    final helperBoxIconThemeData = _getHelperBoxIconThemeData(comboBoxTheme);
    final helperBoxIcon = _getHelperBoxIcon();
    final stateInputBorder = _getStateInputBorder(comboBoxTheme);
    final inputDecorationTheme = comboBoxTheme.inputDecorationTheme;
    final label = widget.label;
    final messageState = widget.messageState;
    final showHelperBox = widget.message != null &&
        (messageState == MessageState.error ||
            messageState == MessageState.success);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          SizedBox(
            child: Text(
              label,
              style: comboBoxTheme.labelStyle,
            ),
          ),
          SizedBox(height: spacings.spacing100),
        ],
        AnimatedContainer(
          decoration: comboBoxTheme.boxDecoration.copyWith(
            boxShadow: focusNode.hasFocus ? [comboBoxTheme.boxShadow] : [],
          ),
          duration: const Duration(milliseconds: 150),
          child: TextField(
            decoration: InputDecoration(
              hintText: widget.hintText,
              enabled: widget.enabled,
              hintStyle: inputDecorationTheme.hintStyle,
              prefixIcon: widget.leadingIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: comboBoxTheme.padding.left,
                        right: spacings.spacing200,
                      ),
                      child: Icon(
                        widget.leadingIcon,
                        size: comboBoxTheme.iconSize,
                        color: abiliaTheme.colors.greyscale.shade900,
                      ),
                    )
                  : null,
              suffixIcon: widget.trailingIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        right: comboBoxTheme.padding.right,
                        left: spacings.spacing200,
                      ),
                      child: GestureDetector(
                        onTap: widget.onTrailingIconOnTap,
                        child: Icon(
                          widget.trailingIcon,
                          size: comboBoxTheme.iconSize,
                          color: abiliaTheme.colors.greyscale.shade900,
                        ),
                      ),
                    )
                  : null,
              enabledBorder:
                  stateInputBorder ?? inputDecorationTheme.enabledBorder,
              focusedBorder:
                  stateInputBorder ?? inputDecorationTheme.focusedBorder,
              focusedErrorBorder:
                  stateInputBorder ?? inputDecorationTheme.focusedErrorBorder,
            ).applyDefaults(inputDecorationTheme),
            textInputAction: widget.textInputAction,
            style: comboBoxTheme.textStyle,
            onChanged: widget.onChanged,
            focusNode: focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
          ),
        ),
        SizedBox(height: spacings.spacing300),
        if (showHelperBox)
          SeagullHelperBox(
            iconThemeData: helperBoxIconThemeData,
            icon: helperBoxIcon,
            text: widget.message ?? '',
            size: widget.size,
            state: messageState ?? MessageState.info,
          ),
      ],
    );
  }

  IconThemeData? _getHelperBoxIconThemeData(
      SeagullComboBoxTheme comboBoxTheme) {
    if (widget.messageState == MessageState.success) {
      return comboBoxTheme.helperBoxIconThemeDataSuccess;
    }
    return null;
  }

  IconData? _getHelperBoxIcon() {
    switch (widget.messageState) {
      case MessageState.error:
        return Symbols.error;
      case MessageState.success:
        return Symbols.check_circle;
      default:
        return null;
    }
  }

  OutlineInputBorder? _getStateInputBorder(SeagullComboBoxTheme comboBoxTheme) {
    switch (widget.messageState) {
      case MessageState.error:
        return comboBoxTheme.inputBorderError;
      case MessageState.success:
        return comboBoxTheme.inputBorderSuccess;
      default:
        return null;
    }
  }

  SeagullComboBoxTheme _getTheme(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    switch (widget.size) {
      case ComboBoxSize.medium:
        return abiliaTheme.comboBox.medium;
      case ComboBoxSize.large:
        return abiliaTheme.comboBox.large;
    }
  }
}
