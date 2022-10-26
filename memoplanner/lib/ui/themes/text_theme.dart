import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/themes/all.dart';

final abiliaTextTheme = GoogleFonts.robotoTextTheme(
  TextTheme(
    headline1: headline1,
    headline2: headline2,
    headline3: headline3,
    headline4: headline4,
    headline5: headline5,
    headline6: headline6,
    subtitle1: subtitle1,
    subtitle2: subtitle2,
    bodyText1: bodyText1,
    bodyText2: bodyText2,
    caption: caption,
    button: button,
    overline: overline,
  ),
);

final headline1 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.headline1,
      fontWeight: light,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headline2 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.headline2,
      fontWeight: light,
      height: 72.0 / 60.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headline3 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.headline3,
      fontWeight: regular,
      height: 56.0 / 48.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headline4 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.headline4,
      fontWeight: regular,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headline5 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.headline5,
      fontWeight: regular,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    headline6 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.headline6,
      fontWeight: medium,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    subtitle1 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.subtitle1,
      fontWeight: medium,
      height: 24.0 / 16.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    subtitle2 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.subtitle2,
      fontWeight: medium,
      height: 24.0 / 14.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyText1 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.bodyText1,
      fontWeight: regular,
      height: 28.0 / 16.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    bodyText2 = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.bodyText2,
      fontWeight: regular,
      height: 20.0 / 14.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    caption = TextStyle(
      color: AbiliaColors.black,
      fontSize: layout.fontSize.caption,
      fontWeight: regular,
      height: 16.0 / 12.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    button = TextStyle(
      color: AbiliaColors.white,
      fontSize: layout.fontSize.button,
      fontWeight: regular,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    overline = TextStyle(
      fontSize: layout.fontSize.overline,
      fontWeight: medium,
      height: 16.0 / 10.0,
      leadingDistribution: TextLeadingDistribution.even,
    );

const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
