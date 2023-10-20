import 'dart:ui';

import 'package:flutter/material.dart';

class IconAndTextBoxTheme extends ThemeExtension<IconAndTextBoxTheme> {
  final TextStyle textStyle;
  final EdgeInsets padding;
  final double iconSize;
  final double iconSpacing;
  final ShapeBorder border;

  const IconAndTextBoxTheme({
    required this.textStyle,
    required this.padding,
    required this.iconSize,
    required this.iconSpacing,
    required this.border,
  });

  @override
  IconAndTextBoxTheme copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    double? iconSize,
    double? iconSpacing,
    ShapeBorder? border,
  }) {
    return IconAndTextBoxTheme(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      iconSpacing: iconSpacing ?? this.iconSpacing,
      border: border ?? this.border,
    );
  }

  @override
  IconAndTextBoxTheme lerp(IconAndTextBoxTheme? other, double t) {
    if (other is! IconAndTextBoxTheme) return this;
    return IconAndTextBoxTheme(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t) ?? textStyle,
      padding: EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      iconSize: lerpDouble(iconSize, other.iconSize, t) ?? iconSize,
      iconSpacing: lerpDouble(iconSpacing, other.iconSpacing, t) ?? iconSpacing,
      border: ShapeBorder.lerp(border, other.border, t) ?? border,
    );
  }
}
