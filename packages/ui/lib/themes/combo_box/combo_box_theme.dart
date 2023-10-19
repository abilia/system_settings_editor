import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/styles/combo_box_styles.dart';
import 'package:ui/themes/combo_box/combo_box_themes.dart';
import 'package:ui/tokens/numericals.dart';

class SeagullComoBoxTheme extends ThemeExtension<SeagullComoBoxTheme> {
  final TextStyle textStyle;
  final InputDecorationTheme inputDecorationTheme;
  final double iconSize, iconGap;
  final EdgeInsets messagePadding;
  final BoxDecoration boxDecoration;
  final BoxShadow boxShadow;

  const SeagullComoBoxTheme({
    required this.textStyle,
    required this.inputDecorationTheme,
    required this.iconSize,
    required this.messagePadding,
    required this.iconGap,
    required this.boxDecoration,
    required this.boxShadow,
  });

  factory SeagullComoBoxTheme.large() => SeagullComoBoxTheme(
        inputDecorationTheme: textFieldInputThemeMedium,
        textStyle: textFieldTextStyleLarge,
        iconSize: numerical800,
        messagePadding: const EdgeInsets.all(numerical600),
        iconGap: numerical200,
        boxDecoration: textFieldBoxDecoration,
        boxShadow: comboBoxBoxShadow,
      );

  factory SeagullComoBoxTheme.medium() => SeagullComoBoxTheme(
        inputDecorationTheme: textFieldInputThemeMedium,
        textStyle: textFieldTextStyleMedium,
        iconSize: numerical600,
        messagePadding: const EdgeInsets.all(numerical300),
        iconGap: numerical200,
        boxDecoration: textFieldBoxDecoration,
        boxShadow: comboBoxBoxShadow,
      );

  @override
  SeagullComoBoxTheme copyWith({
    InputDecorationTheme? inputDecorationTheme,
    TextStyle? textStyle,
    Widget? leading,
    Widget? trailing,
    bool? obscureText,
    double? iconSize,
    EdgeInsets? messagePadding,
    double? iconGap,
    BoxDecoration? boxDecoration,
    BoxShadow? boxShadow,
  }) {
    return SeagullComoBoxTheme(
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      textStyle: textStyle ?? this.textStyle,
      iconSize: iconSize ?? this.iconSize,
      messagePadding: messagePadding ?? this.messagePadding,
      iconGap: iconGap ?? this.iconGap,
      boxDecoration: boxDecoration ?? this.boxDecoration,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }

  @override
  SeagullComoBoxTheme lerp(covariant SeagullComoBoxTheme? other, double t) {
    return copyWith(
      iconSize: lerpDouble(iconSize, other?.iconSize, t),
      textStyle: TextStyle.lerp(textStyle, other?.textStyle, t),
      messagePadding: EdgeInsets.lerp(messagePadding, other?.messagePadding, t),
      iconGap: lerpDouble(iconGap, other?.iconGap, t),
      boxDecoration: boxDecoration.lerpTo(other?.boxDecoration, t),
    );
  }
}
