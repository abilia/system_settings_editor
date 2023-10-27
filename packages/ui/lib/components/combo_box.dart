import 'package:flutter/material.dart';
import 'package:ui/components/helper_box.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/combo_box/combo_box_themes.dart';
import 'package:ui/utils/sizes.dart';
import 'package:ui/utils/states.dart';

typedef ComboBoxSize = MediumLargeSize;

class SeagullComboBox extends StatefulWidget {
  final String? hintText;
  final String? label;
  final String? helperBoxMessage;
  final MessageState? messageState;
  final IconData? helperBoxIcon;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool obscureText;
  final bool enabled;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final ComboBoxSize size;
  final VoidCallback? onTrailingIconOnTap;
  final Function(String)? onSubmitted;

  const SeagullComboBox({
    required this.size,
    this.controller,
    this.hintText,
    this.onChanged,
    this.label,
    this.helperBoxMessage,
    this.maxLength,
    this.messageState,
    this.helperBoxIcon,
    this.leadingIcon,
    this.trailingIcon,
    this.textInputAction,
    this.onTrailingIconOnTap,
    this.onSubmitted,
    this.enabled = true,
    this.obscureText = false,
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
    final stateInputBorder = _getStateInputBorder(comboBoxTheme);
    final inputDecorationTheme = comboBoxTheme.inputDecorationTheme;
    final label = widget.label;
    final messageState = widget.messageState;
    final helperBoxMessage = widget.helperBoxMessage;
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
          decoration: focusNode.hasFocus
              ? comboBoxTheme.boxDecorationSelected
              : comboBoxTheme.boxDecoration,
          duration: const Duration(milliseconds: 150),
          child: IconTheme(
            data: comboBoxTheme.iconThemeData,
            child: TextField(
              textInputAction: widget.textInputAction,
              style: comboBoxTheme.textStyle,
              onChanged: widget.onChanged,
              focusNode: focusNode,
              controller: widget.controller,
              obscureText: widget.obscureText,
              onSubmitted: widget.onSubmitted,
              maxLength: widget.maxLength,
              decoration: InputDecoration(
                hintText: widget.hintText,
                enabled: widget.enabled,
                counterText: '',
                hintStyle: inputDecorationTheme.hintStyle,
                prefixIcon: widget.leadingIcon != null
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: comboBoxTheme.padding.left,
                          right: spacings.spacing200,
                        ),
                        child: Icon(
                          widget.leadingIcon,
                          size: comboBoxTheme.iconThemeData.size,
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
                            size: comboBoxTheme.iconThemeData.size,
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
            ),
          ),
        ),
        if (helperBoxMessage != null && messageState != null) ...[
          SizedBox(height: spacings.spacing300),
          SeagullHelperBox(
            iconThemeData: helperBoxIconThemeData,
            icon: widget.helperBoxIcon,
            text: widget.helperBoxMessage ?? '',
            size: widget.size,
            state: messageState,
          ),
        ]
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
