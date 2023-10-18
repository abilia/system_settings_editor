import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/components/collapsable_widget.dart';
import 'package:ui/styles/combo_box_styles.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/numericals.dart';

class SeagullComoBox extends StatefulWidget {
  final String? hintText;
  final String? label;
  final String? message;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  const SeagullComoBox({
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
    return _SeagullComoBoxState();
  }
}

class _SeagullComoBoxState extends State<SeagullComoBox> {
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
              style: textFieldTextStyleMedium.copyWith(
                color: AbiliaColors.greyscale700,
              ),
            ),
          ),
        AnimatedContainer(
          decoration: BoxDecoration(
            boxShadow: selected
                ? [
                    const BoxShadow(
                      color: AbiliaColors.primary200,
                      spreadRadius: numerical200,
                    ),
                  ]
                : [],
            borderRadius: const BorderRadius.all(
              Radius.circular(numerical200),
            ),
            color: AbiliaColors.greyscale000,
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
        CollapsableWidget(
          collapsed: widget.message == null,
          child: SizedBox(
            height: numerical300,
            child: Padding(
              padding: theme.messagePadding,
              child: Container(
                color: AbiliaColors.peach100,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Symbols.error,
                      size: theme.iconSize,
                    ),
                    Text(
                      widget.message ?? '',
                      style: theme.textStyle.copyWith(
                        color: AbiliaColors.greyscale700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
