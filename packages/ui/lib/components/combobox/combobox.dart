import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/action_button/action_button_theme.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

class Combobox extends StatefulWidget {
  final String? hintText;
  final String? label;
  final String? errorMessage;
  final Function(String)? onChanged;
  final FocusNode focusNode = FocusNode();
  final Widget? leading;
  final Widget? trailing;
  final TextEditingController? controller;

  Combobox({
    this.hintText,
    this.controller,
    this.onChanged,
    this.leading,
    this.trailing,
    this.label,
    this.errorMessage,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _ComboboxState();
  }
}

class _ComboboxState extends State<Combobox> {
  bool selected = false;
  bool hasText = false;
  @override
  Widget build(BuildContext context) {
    widget.focusNode.addListener(
      () => setState(() => selected = widget.focusNode.hasFocus),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: numerical100),
            child: Text(
              widget.label!,
              style: AbiliaFonts.primary425.copyWith(
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
              contentPadding: textFieldInputTheme900.contentPadding,
              focusColor: textFieldInputTheme900.focusColor,
              fillColor: textFieldInputTheme900.fillColor,
              border: textFieldInputTheme900.border,
              suffix: widget.trailing,
              prefix: widget.leading,
            ),
            style: textFieldTextStyle900,
            onChanged: widget.onChanged,
            focusNode: widget.focusNode,
            controller: widget.controller,
          ),
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: numerical100),
            child: Container(
              color: AbiliaColors.peach100,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    MdiIcons.alert,
                    size: numerical600,
                  ),
                  Text(
                    widget.errorMessage!,
                    style: AbiliaFonts.primary425.copyWith(
                      color: AbiliaColors.greyscale700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
