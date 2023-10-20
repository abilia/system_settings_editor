import 'package:flutter/material.dart';
import 'package:ui/components/collapsable_widget.dart';
import 'package:ui/components/helper_box.dart';
import 'package:ui/states.dart';
import 'package:ui/styles/combo_box_styles.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/combo_box/combo_box_themes.dart';

enum ComboBoxSize {
  medium,
  large,
}

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
              hintStyle: comboBoxTheme.inputDecorationTheme.hintStyle,
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
              enabledBorder: _getBorder(widget.messageState) ??
                  comboBoxTheme.inputDecorationTheme.enabledBorder,
              focusedBorder: _getBorder(widget.messageState) ??
                  comboBoxTheme.inputDecorationTheme.focusedBorder,
              focusedErrorBorder: _getBorder(widget.messageState) ??
                  comboBoxTheme.inputDecorationTheme.focusedErrorBorder,
            ).applyDefaults(comboBoxTheme.inputDecorationTheme),
            textInputAction: widget.textInputAction,
            style: comboBoxTheme.textStyle,
            onChanged: widget.onChanged,
            focusNode: focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: spacings.spacing300),
          child: CollapsableWidget(
            collapsed: !showHelperBox,
            child: messageState != null
                ? SeagullHelperBox(
                    iconTheme: _getIconTheme(widget.messageState),
                    text: widget.message ?? '',
                    size: widget.size == ComboBoxSize.large
                        ? HelperBoxSize.large
                        : HelperBoxSize.medium,
                    state: messageState,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  IconTheme? _getIconTheme(MessageState? state) {
    switch (state) {
      case MessageState.error:
        return iconThemeError;
      case MessageState.success:
        return iconThemeSuccess;
      default:
        return null;
    }
  }

  OutlineInputBorder? _getBorder(MessageState? state) {
    switch (state) {
      case MessageState.error:
        return errorBorder;
      case MessageState.success:
        return successBorder;
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
