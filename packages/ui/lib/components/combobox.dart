import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

final OutlineInputBorder roundBorder = defaultBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(width: numerical1px),
);

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

final defaultBorder = OutlineInputBorder(
  borderRadius: const BorderRadius.all(
    Radius.circular(numerical200),
  ),
  borderSide: borderSideGrey300.copyWith(
    width: numerical1px,
  ),
);

final errorBorder = defaultBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(color: BorderColors.focus),
);

final selectedBorder = defaultBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(color: BorderColors.active),
);

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
            padding: const EdgeInsets.only(bottom: numerical100),
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
          ),
          duration: const Duration(milliseconds: 250),
          child: TextField(
            decoration: InputDecoration(
              hintText: widget.hintText,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: numerical300, horizontal: numerical400),
              focusColor: AbiliaColors.greyscale000,
              fillColor: AbiliaColors.greyscale000,
              border: MaterialStateOutlineInputBorder.resolveWith(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.focused)) {
                  return selectedBorder;
                }
                if (states.contains(MaterialState.error)) {
                  return errorBorder;
                }
                return defaultBorder;
              }),
              suffix: widget.trailing,
              prefix: widget.leading,
            ),
            style:
                MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
              if (states.contains(MaterialState.error)) {
                return AbiliaFonts.primary425;
              }
              if (states.contains(MaterialState.focused)) {
                return AbiliaFonts.primary425;
              }
              return AbiliaFonts.primary425
                  .copyWith(color: FontColors.secondary);
            }),
            onChanged: widget.onChanged,
            focusNode: widget.focusNode,
            controller: widget.controller,
          ),
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: numerical100),
            child: Expanded(
                child: Row(
              children: [
                Icon(
                  MdiIcons.alert,
                  size: numerical600,
                ),
                Text(
                  widget.label!,
                  style: AbiliaFonts.primary425.copyWith(
                    color: AbiliaColors.greyscale700,
                  ),
                ),
              ],
            )),
          ),
      ],
    );
  }
}
