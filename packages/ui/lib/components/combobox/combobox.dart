import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/components/collapsable_widget.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/combobox/combobox_theme.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/numericals.dart';

class Combobox extends StatefulWidget {
  final ComboboxTheme Function(ComboboxTheme) themeBuilder;
  final String? hintText;
  final String? label;
  final String? message;
  final Function(String)? onChanged;
  final FocusNode focusNode = FocusNode();
  final TextEditingController? controller;

  Combobox({
    required this.themeBuilder,
    ComboboxTheme? mixTheme,
    this.hintText,
    this.controller,
    this.onChanged,
    this.label,
    this.message,
    super.key,
  });

  factory Combobox.large({
    ComboboxSubTheme? subTheme,
    controller,
    onChanged,
    leading,
    trailing,
    label,
    message,
    key,
    bool? obscureText,
  }) =>
      Combobox(
        themeBuilder: (comboBoxTheme) => subTheme != null
            ? ComboboxTheme.medium().applySubTheme(subTheme)
            : ComboboxTheme.medium(),
        controller: controller,
        onChanged: onChanged,
        label: label,
        key: key,
      );

  factory Combobox.medium({
    ComboboxSubTheme? subTheme,
    controller,
    onChanged,
    leading,
    trailing,
    label,
    message,
    key,
    bool? obscureText,
  }) =>
      Combobox(
        themeBuilder: (comboBoxTheme) =>
            ComboboxTheme.medium().applySubTheme(subTheme),
        controller: controller,
        onChanged: onChanged,
        label: label,
        message: message,
        key: key,
      );

  @override
  State<StatefulWidget> createState() {
    return _ComboboxState();
  }

  Combobox copyWith({
    hintText,
    controller,
    onChanged,
    leading,
    trailing,
    label,
    message,
    obscureText,
  }) =>
      Combobox(
        themeBuilder: themeBuilder,
        hintText: hintText ?? this.hintText,
        controller: controller ?? this.controller,
        label: label ?? this.label,
        message: message ?? this.message,
      );
}

class _ComboboxState extends State<Combobox> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    final comboBoxTheme = widget.themeBuilder(abiliaTheme.comboboxTheme);
    widget.focusNode.addListener(
      () => setState(
        () => selected = widget.focusNode.hasFocus,
      ),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: numerical200),
            child: Text(
              widget.label!,
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
                    prefix: comboBoxTheme.leading,
                    suffix: comboBoxTheme.trailing)
                .applyDefaults(comboBoxTheme.inputDecorationTheme),
            style: comboBoxTheme.textStyle,
            onChanged: widget.onChanged,
            focusNode: widget.focusNode,
            controller: widget.controller,
            obscureText: comboBoxTheme.obscureText ?? false,
          ),
        ),
        CollapsableWidget(
          collapsed: widget.message == null,
          child: SizedBox(
            height: numerical300,
            child: Padding(
              padding: comboBoxTheme.messagePadding,
              child: Container(
                color: AbiliaColors.peach100,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Symbols.error,
                      size: comboBoxTheme.iconSize,
                    ),
                    Text(
                      widget.message ?? '',
                      style: comboBoxTheme.textStyle.copyWith(
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
