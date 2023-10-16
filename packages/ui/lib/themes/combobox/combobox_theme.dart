import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/styles/styles.dart';
import 'package:ui/themes/combobox/combobox_themes.dart';
import 'package:ui/tokens/numericals.dart';

class ComboboxTheme extends ComboboxSubTheme {
  final TextStyle textStyle;
  final InputDecorationTheme inputDecorationTheme;
  final double iconSize;
  final EdgeInsets messagePadding;

  const ComboboxTheme({
    required this.textStyle,
    required this.inputDecorationTheme,
    required this.iconSize,
    required this.messagePadding,
    super.leading,
    super.trailing,
    super.obscureText = false,
  });

  factory ComboboxTheme.large() => ComboboxTheme(
        inputDecorationTheme: textFieldInputThemeMedium,
        textStyle: textFieldTextStyleLarge,
        iconSize: numerical800,
        messagePadding: const EdgeInsets.all(numerical600),
      );

  factory ComboboxTheme.medium() => ComboboxTheme(
        inputDecorationTheme: textFieldInputThemeMedium,
        textStyle: textFieldTextStyleMedium,
        iconSize: numerical600,
        messagePadding: const EdgeInsets.all(numerical300),
      );

  ComboboxTheme applySubTheme(ComboboxSubTheme? subTheme) => subTheme == null
      ? this
      : copyWith(
          inputDecorationTheme: inputDecorationTheme,
          leading: subTheme.leading ?? leading,
          trailing: subTheme.trailing ?? trailing,
          obscureText: subTheme.obscureText ?? obscureText,
        );

  @override
  ComboboxTheme copyWith({
    InputDecorationTheme? inputDecorationTheme,
    TextStyle? textStyle,
    Widget? leading,
    Widget? trailing,
    bool? obscureText,
    double? iconSize,
    EdgeInsets? messagePadding,
  }) {
    return ComboboxTheme(
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      textStyle: textStyle ?? this.textStyle,
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      obscureText: obscureText ?? this.obscureText,
      iconSize: iconSize ?? this.iconSize,
      messagePadding: messagePadding ?? this.messagePadding,
    );
  }

  @override
  ComboboxTheme lerp(covariant ComboboxTheme? other, double t) {
    return copyWith(
      iconSize: lerpDouble(iconSize, other?.iconSize, t),
      textStyle: TextStyle.lerp(textStyle, other?.textStyle, t),
      messagePadding: EdgeInsets.lerp(messagePadding, other?.messagePadding, t),
    );
  }
}

class ComboboxSubTheme extends ThemeExtension<ComboboxSubTheme> {
  final Widget? leading;
  final Widget? trailing;
  final bool? obscureText;

  const ComboboxSubTheme({
    this.leading,
    this.trailing,
    this.obscureText = false,
  });

  factory ComboboxSubTheme.dropdown(ComboboxTheme baseTheme) =>
      baseTheme.copyWith(
        leading: const Icon(Symbols.expand_more),
      );

  factory ComboboxSubTheme.email(ComboboxTheme baseTheme) => baseTheme.copyWith(
        leading: const Icon(Symbols.email),
      );

  factory ComboboxSubTheme.search(ComboboxTheme baseTheme) =>
      baseTheme.copyWith(
        leading: const Icon(Symbols.search),
      );

  factory ComboboxSubTheme.password() => const ComboboxSubTheme(
        leading: Icon(Symbols.key),
        trailing: Icon(Symbols.visibility),
        obscureText: true,
      );

  @override
  ComboboxSubTheme copyWith({
    Widget? leading,
    Widget? trailing,
    bool? obscureText,
  }) {
    return ComboboxSubTheme(
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      obscureText: obscureText ?? this.obscureText ?? false,
    );
  }

  @override
  ComboboxSubTheme lerp(covariant ComboboxSubTheme? other, double t) {
    return other ?? this;
  }
}
