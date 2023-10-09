import 'package:flutter/material.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/fonts.dart';
import 'package:ui/tokens/numericals.dart';

final RoundedRectangleBorder roundBorder = baseBorder.copyWith(
  side: borderSideGrey300.copyWith(width: numerical1px),
);

class Combobox extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final FocusNode focusNode = FocusNode();
  final Widget? leading;
  final Iterable<Widget>? trailing;
  final TextEditingController controller;

  Combobox({
    required this.hintText,
    required this.controller,
    this.onChanged,
    this.leading,
    this.trailing,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _ComboboxState();
  }
}

final defaultBorder = baseBorder.copyWith(
  side: borderSideGrey300.copyWith(
    width: numerical1px,
  ),
);

final errorBorder = defaultBorder.copyWith(
  side: borderSideGrey300.copyWith(color: BorderColors.focus),
);

final selectedBorder = defaultBorder.copyWith(
  side: borderSideGrey300.copyWith(color: BorderColors.active),
);

class _ComboboxState extends State<Combobox> {
  bool selected = false;
  bool hasText = false;
  @override
  Widget build(BuildContext context) {
    widget.focusNode.addListener(
      () {
        setState(() => selected = widget.focusNode.hasFocus);
      },
    );
    return Container(
      decoration: BoxDecoration(
        boxShadow: selected
            ? [
                const BoxShadow(
                  color: AbiliaColors.primary200,
                  spreadRadius: numerical200,
                )
              ]
            : [],
        borderRadius: const BorderRadius.all(
          Radius.circular(numerical200),
        ),
      ),
      child: SearchBar(
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        leading: widget.leading,
        trailing: widget.trailing,
        controller: widget.controller,
        shape: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return selectedBorder;
          }
          if (states.contains(MaterialState.error)) {
            return errorBorder;
          }
          return defaultBorder;
        }),
        elevation: MaterialStateProperty.all(numerical000),
        backgroundColor: backgroundGrey,
        textStyle: MaterialStateProperty.resolveWith(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.error)) {
              return AbiliaFonts.primary425;
            }
            if (states.contains(MaterialState.focused)) {
              return AbiliaFonts.primary425;
            }
            return AbiliaFonts.primary425.copyWith(color: FontColors.secondary);
          },
        ),
        hintText: widget.hintText,
      ),
    );
  }
}
