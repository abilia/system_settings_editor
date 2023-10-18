import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/components/collapsable_widget.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/numericals.dart';

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

  const SeagullComboBox({
    this.hintText,
    this.controller,
    this.onChanged,
    this.label,
    this.message,
    this.leadingIcon,
    this.trailingIcon,
    this.textInputAction,
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
          decoration: BoxDecoration(
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AbiliaColors.primary,
                      spreadRadius: numerical200,
                    ),
                  ]
                : [],
            borderRadius: const BorderRadius.all(
              Radius.circular(numerical200),
            ),
            color: AbiliaColors.greyscale,
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
            collapsed: widget.message == null,
            child: Container(
              color: AbiliaColors.peach.shade100,
              height: numerical900,
              child: Padding(
                padding: theme.messagePadding,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Symbols.error,
                      size: theme.iconSize,
                    ),
                    SizedBox(width: theme.iconGap),
                    Text(
                      widget.message ?? '',
                      style: theme.textStyle.copyWith(
                        color: SurfaceColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
