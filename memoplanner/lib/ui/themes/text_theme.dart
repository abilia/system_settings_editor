import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoplanner/ui/themes/all.dart';

final abiliaTextTheme = GoogleFonts.robotoTextTheme(
  TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  ),
);

final displayLarge = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.displayLarge,
      fontWeight: light,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    displayMedium = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.displayMedium,
      fontWeight: light,
      height: 72.0 / 60.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    displaySmall = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.displaySmall,
      fontWeight: regular,
      height: 56.0 / 48.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineMedium = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.headlineMedium,
      fontWeight: regular,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headlineSmall = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.headlineSmall,
      fontWeight: regular,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleLarge = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.titleLarge,
      fontWeight: medium,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleMedium = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.titleMedium,
      fontWeight: medium,
      height: 24.0 / 16.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    titleSmall = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.titleSmall,
      fontWeight: medium,
      height: 24.0 / 14.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyLarge = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.bodyLarge,
      fontWeight: regular,
      height: 28.0 / 16.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyMedium = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.bodyMedium,
      fontWeight: regular,
      height: 20.0 / 14.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodySmall = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.bodySmall,
      fontWeight: regular,
      height: 16.0 / 12.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelLarge = TextStyle(
      color: AbiliaColors.white,
      fontSize: layout.fontSize.labelLarge,
      fontWeight: regular,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    labelSmall = TextStyle(
      fontSize: layout.fontSize.labelSmall,
      fontWeight: medium,
      height: 16.0 / 10.0,
      leadingDistribution: TextLeadingDistribution.even,
    );

const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
