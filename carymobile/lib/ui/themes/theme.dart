import 'package:carymessenger/ui/themes/cary_theme.dart';
import 'package:carymessenger/ui/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'text_styles.dart';

final caryLightTheme = ThemeData.from(
  colorScheme: const ColorScheme.light(primary: abiliaBlack80),
  textTheme: GoogleFonts.robotoTextTheme(
    const TextTheme(
      titleLarge: titleMedium,
      titleMedium: headlineSmall,
      headlineSmall: headlineSmall,
      bodyMedium: bodyMedium,
    ),
  ),
  useMaterial3: true,
).copyWith(
  extensions: [CaryTheme.expanded],
  filledButtonTheme: const FilledButtonThemeData(
    style: blackActionCaryMobileButtonStyle,
  ),
  inputDecorationTheme: inputDecorationTheme,
  iconTheme: const IconThemeData(size: 32),
);

ThemeData collapsed(ThemeData data) {
  return data.copyWith(
      textTheme: data.textTheme.copyWith(
        titleLarge: titleLarge,
        titleMedium: titleMedium,
      ),
      extensions: [CaryTheme.collapsed]);
}

const borderRadius = BorderRadius.all(Radius.circular(16));

const blackActionCaryMobileButtonStyle = ButtonStyle(
  textStyle: MaterialStatePropertyAll(actionButtonTextStyle),
  foregroundColor: MaterialStatePropertyAll(Colors.white),
  backgroundColor: MaterialStatePropertyAll(Colors.black),
  minimumSize: MaterialStatePropertyAll(Size.fromHeight(64)),
  shape: MaterialStatePropertyAll(
    RoundedRectangleBorder(borderRadius: borderRadius),
  ),
  iconSize: MaterialStatePropertyAll(32),
);

final greenActionCaryMobileButtonStyle =
    blackActionCaryMobileButtonStyle.copyWith(
  backgroundColor: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) return abiliaGreen40;
      return abiliaGreen120;
    },
  ),
  shape: MaterialStateProperty.resolveWith(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) return null;
      return const RoundedRectangleBorder(
        side: BorderSide(width: 2, color: abiliaGreen120),
        borderRadius: borderRadius,
      );
    },
  ),
);

const inputDecorationTheme = InputDecorationTheme(
  border: inputBorder,
  focusedBorder: inputBorder,
  enabledBorder: inputBorder,
);

const inputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: abiliaWhite140, width: 2),
  borderRadius: borderRadius,
);
