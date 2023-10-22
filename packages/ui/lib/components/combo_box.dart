import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/components/helper_box.dart';
import 'package:ui/src/components/collapsable_widget.dart';
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
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _SeagullComboBoxState();
  }
}

class _SeagullComboBoxState extends State<SeagullComboBox> {
  final FocusNode focusNode = FocusNode();
  bool selected = false;

  @override
  void initState() {
    focusNode.addListener(
      () => setState(
        () => selected = focusNode.hasFocus,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final spacings = AbiliaTheme.of(context).spacings;
    final comboBoxTheme = _getTheme(context);
    final helperBoxIconThemeData = _getHelperBoxIconThemeData(comboBoxTheme);
    final helperBoxIcon = _getHelperBoxIcon();
    final inputBorder = _getInputBorder(comboBoxTheme);
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
            boxShadow: selected ? [comboBoxTheme.boxShadow] : [],
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
                      ),
                    )
                  : null,
              suffixIcon: widget.trailingIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        right: comboBoxTheme.padding.right,
                        left: spacings.spacing200,
                      ),
                      child: Icon(
                        widget.trailingIcon,
                        size: comboBoxTheme.iconSize,
                      ),
                    )
                  : null,
              enabledBorder: inputBorder ?? inputDecorationTheme.enabledBorder,
              focusedBorder: inputBorder ?? inputDecorationTheme.focusedBorder,
              focusedErrorBorder:
                  inputBorder ?? inputDecorationTheme.focusedErrorBorder,
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
        CollapsableWidget(
          collapsed: !showHelperBox,
          child: SeagullHelperBox(
            iconThemeData: helperBoxIconThemeData,
            icon: helperBoxIcon,
            text: widget.message ?? '',
            size: widget.size,
            state: messageState ?? MessageState.info,
          ),
        ),
      ],
    );
  }

  IconThemeData? _getHelperBoxIconThemeData(
      SeagullComboBoxTheme comboBoxTheme) {
    switch (widget.messageState) {
      case MessageState.error:
        return comboBoxTheme.helperBoxIconThemeDataError;
      case MessageState.success:
        return comboBoxTheme.helperBoxIconThemeDataSuccess;
      default:
        return null;
    }
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

  OutlineInputBorder? _getInputBorder(SeagullComboBoxTheme comboBoxTheme) {
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
