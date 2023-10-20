import 'package:flutter/material.dart';
import 'package:ui/components/collapsable_widget.dart';
import 'package:ui/components/helper_box.dart';
import 'package:ui/src/colors.dart';
import 'package:ui/src/numericals.dart';
import 'package:ui/states.dart';
import 'package:ui/styles/combo_box_styles.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/combo_box/combo_box_themes.dart';

class SeagullComboBox extends StatefulWidget {
  final String? hintText;
  final String? label;
  final String? message;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final MessageState? messageState;

  const SeagullComboBox({
    this.controller,
    this.hintText,
    this.onChanged,
    this.label,
    this.message,
    this.leadingIcon,
    this.trailingIcon,
    this.textInputAction,
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
    final theme = AbiliaTheme.of(context).comboBox;
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
        if (label != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: numerical200),
            child: Text(
              label,
              style: theme.textStyle.copyWith(
                color: SurfaceColors.textSecondary,
              ),
            ),
          ),
        AnimatedContainer(
          decoration: theme.boxDecoration.copyWith(
            boxShadow: selected ? [theme.boxShadow] : [],
          ),
          duration: const Duration(milliseconds: 150),
          child: TextField(
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon:
                  widget.leadingIcon != null ? Icon(widget.leadingIcon) : null,
              suffixIcon: widget.trailingIcon != null
                  ? Icon(widget.trailingIcon)
                  : null,
              enabledBorder: _getBorder(widget.messageState) ??
                  theme.inputDecorationTheme.enabledBorder,
              focusedBorder: _getBorder(widget.messageState) ??
                  theme.inputDecorationTheme.focusedBorder,
              focusedErrorBorder: _getBorder(widget.messageState) ??
                  theme.inputDecorationTheme.focusedErrorBorder,
            ).applyDefaults(theme.inputDecorationTheme),
            textInputAction: widget.textInputAction,
            style: theme.textStyle,
            onChanged: widget.onChanged,
            focusNode: focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: numerical300),
          child: CollapsableWidget(
            collapsed: !showHelperBox,
            child: messageState != null
                ? SeagullHelperBox(
                    iconTheme: _getIconTheme(widget.messageState),
                    text: widget.message ?? '',
                    size: HelperBoxSize.medium,
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
}
