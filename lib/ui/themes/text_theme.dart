import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/themes/all.dart';
import 'package:seagull/utils/all.dart';

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
      fontSize: Lay.out.font.headline1,
      fontWeight: light,
    ),
    headline2 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.headline2,
      fontWeight: light,
      height: 72.0 / 60.0,
    ),
    headline3 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.headline3,
      fontWeight: regular,
      height: 56.0 / 48.0,
    ),
    headline4 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.headline4,
      fontWeight: regular,
    ),
    headline5 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.headline5,
      fontWeight: regular,
    ),
    headline6 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.headline6,
      fontWeight: medium,
    ),
    subtitle1 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.subtitle1,
      fontWeight: medium,
      height: 24.0 / 16.0,
    ),
    subtitle2 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.subtitle2,
      fontWeight: medium,
      height: 24.0 / 14.0,
    ),
    bodyText1 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.bodyText1,
      fontWeight: regular,
      height: 28.0 / 16.0,
    ),
    bodyText2 = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.bodyText2,
      fontWeight: regular,
      height: 20.0 / 14.0,
    ),
    caption = TextStyle(
      color: AbiliaColors.black,
      fontSize: Lay.out.font.caption,
      fontWeight: regular,
      height: 16.0 / 12.0,
    ),
    button = TextStyle(
      color: AbiliaColors.white,
      fontSize: Lay.out.font.button,
      fontWeight: regular,
      height: 1,
    ),
    overline = TextStyle(
      fontSize: Lay.out.font.overline,
      fontWeight: medium,
      height: 16.0 / 10.0,
    );

final headline6FontSize = Lay.out.font.headline6, catptionFontSize = 12.s;
const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
