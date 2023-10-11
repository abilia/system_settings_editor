import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

const search = ComboboxTheme(
  leading: Icon(Symbols.search),
);

const password = ComboboxTheme(
  leading: Icon(Symbols.key),
  trailing: Icon(Symbols.visibility),
  obfuscate: true,
);

const email = ComboboxTheme(
  leading: Icon(Symbols.email),
);

const dropdown = ComboboxTheme(
  trailing: Icon(Symbols.expand_more),
);

class ComboboxTheme extends ThemeExtension<ComboboxTheme> {
  final Widget? leading;
  final Widget? trailing;
  final bool obfuscate;

  const ComboboxTheme({
    this.leading,
    this.trailing,
    this.obfuscate = false,
  });

  @override
  ThemeExtension<ComboboxTheme> copyWith(
      {Widget? leading, Widget? trailing, bool? obfuscate}) {
    return ComboboxTheme(
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      obfuscate: obfuscate ?? this.obfuscate,
    );
  }

  @override
  ThemeExtension<ComboboxTheme> lerp(
      covariant ThemeExtension<ComboboxTheme>? other, double t) {
    return other ?? this;
  }
}
