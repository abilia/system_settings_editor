import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/styles/combo_box_styles.dart';
import 'package:ui/themes/combo_box/combo_box_themes.dart';
import 'package:ui/tokens/numericals.dart';

class SeagullComoBoxTheme extends ThemeExtension<SeagullComoBoxTheme> {
  final TextStyle textStyle;
  final InputDecorationTheme inputDecorationTheme;
  final double iconSize;
  final EdgeInsets messagePadding;

  const SeagullComoBoxTheme({
    required this.textStyle,
    required this.inputDecorationTheme,
    required this.iconSize,
    required this.messagePadding,
  });

  factory SeagullComoBoxTheme.large() => SeagullComoBoxTheme(
        inputDecorationTheme: textFieldInputThemeMedium,
        textStyle: textFieldTextStyleLarge,
        iconSize: numerical800,
        messagePadding: const EdgeInsets.all(numerical600),
      );

  factory SeagullComoBoxTheme.medium() => SeagullComoBoxTheme(
        inputDecorationTheme: textFieldInputThemeMedium,
        textStyle: textFieldTextStyleMedium,
        iconSize: numerical600,
        messagePadding: const EdgeInsets.all(numerical300),
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
  }) {
    return SeagullComoBoxTheme(
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      textStyle: textStyle ?? this.textStyle,
      iconSize: iconSize ?? this.iconSize,
      messagePadding: messagePadding ?? this.messagePadding,
    );
  }

  @override
  SeagullComoBoxTheme lerp(covariant SeagullComoBoxTheme? other, double t) {
    return copyWith(
      iconSize: lerpDouble(iconSize, other?.iconSize, t),
      textStyle: TextStyle.lerp(textStyle, other?.textStyle, t),
      messagePadding: EdgeInsets.lerp(messagePadding, other?.messagePadding, t),
    );
  }
}
