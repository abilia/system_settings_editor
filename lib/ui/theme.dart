import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

const double smallIconSize = 24, defaultIconSize = 32, hugeIconSize = 96;

ThemeData abiliaTheme = ThemeData(
  primaryColorBrightness: Brightness.light,
  scaffoldBackgroundColor: AbiliaColors.white110,
  primaryColor: AbiliaColors.black,
  accentColor: AbiliaColors.black,
  unselectedWidgetColor: AbiliaColors.white140,
  fontFamily: 'Roboto',
  inputDecorationTheme: inputDecorationTheme,
  textTheme: abiliaTextTheme,
  buttonTheme: baseButtonTheme,
  buttonColor: AbiliaColors.transparentBlack20,
  highlightColor: AbiliaColors.transparentBlack40,
  iconTheme: IconThemeData(size: defaultIconSize, color: AbiliaColors.black),
  cursorColor: AbiliaColors.black,
  textSelectionHandleColor: AbiliaColors.black,
  appBarTheme: AppBarTheme(color: AbiliaColors.black80),
  disabledColor: AbiliaColors.red40,
  errorColor: AbiliaColors.red,
  textSelectionColor: AbiliaColors.white120,
  bottomAppBarTheme: BottomAppBarTheme(color: AbiliaColors.black80),
  cupertinoOverrideTheme: CupertinoThemeData(primaryColor: AbiliaColors.black),
  toggleableActiveColor: AbiliaColors.green,
  dividerTheme: const DividerThemeData(
    color: AbiliaColors.white120,
    endIndent: 12.0,
    thickness: 1.0,
    space: 0.0,
  ),
);

const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16),
    focusedBorder: inputBorder,
    enabledBorder: inputBorder,
    errorBorder: redOutlineInputBorder,
    focusedErrorBorder: redOutlineInputBorder,
    filled: true,
    // Unfortunatly, can't use the validation without showing some error text, set the font size 0
    errorStyle: TextStyle(height: 0),
    fillColor: AbiliaColors.white);

const Radius radius = Radius.circular(12);
const BorderRadius borderRadius = BorderRadius.all(radius);
const BorderRadius notUpperLeft = BorderRadius.only(
  topRight: radius,
  bottomRight: radius,
  bottomLeft: radius,
);

const BorderSide borderSide = BorderSide(color: AbiliaColors.white140);
const Border currentActivityBorder =
    Border.fromBorderSide(BorderSide(color: AbiliaColors.red, width: 2.0));
const Border errorBorder =
    Border.fromBorderSide(BorderSide(color: AbiliaColors.red));
const borderGreen =
    Border.fromBorderSide(BorderSide(color: AbiliaColors.green, width: 2.0));
const borderOrange =
    Border.fromBorderSide(BorderSide(color: AbiliaColors.orange40, width: 2.0));
const border = Border.fromBorderSide(borderSide);
const ligthShapeBorder = RoundedRectangleBorder(
  borderRadius: borderRadius,
  side: BorderSide(color: AbiliaColors.transparentWhite30),
);
const darkShapeBorder = RoundedRectangleBorder(
  borderRadius: borderRadius,
  side: BorderSide(color: AbiliaColors.transparentBlack30),
);
const BoxDecoration boxDecoration = BoxDecoration(
  borderRadius: borderRadius,
  border: border,
);
const BoxDecoration disabledBoxDecoration = BoxDecoration(
  borderRadius: borderRadius,
  color: AbiliaColors.transparentWhite40,
);
const BoxDecoration currentBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: currentActivityBorder,
);
const BoxDecoration whiteBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: border,
);
const BoxDecoration greenBoarderWhiteBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: borderGreen,
);
const BoxDecoration whiteNoBorderBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
);
const BoxDecoration warningBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: borderOrange,
);
const inactiveGrey = AbiliaColors.white110;
const BoxDecoration inactiveBoxDecoration = BoxDecoration(
  color: inactiveGrey,
  borderRadius: borderRadius,
  border: border,
);
const BoxDecoration errorBoxDecoration = BoxDecoration(
  borderRadius: borderRadius,
  border: errorBorder,
);
const BoxDecoration whiteErrorBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: errorBorder,
);

BoxDecoration getBoxDecoration(bool current, bool inactive) => inactive
    ? inactiveBoxDecoration
    : current
        ? currentBoxDecoration
        : whiteBoxDecoration;

BoxDecoration selectedBoxDecoration(bool selected) =>
    selected ? greenBoarderWhiteBoxDecoration : whiteBoxDecoration;

const OutlineInputBorder inputBorder = OutlineInputBorder(
  borderSide: borderSide,
  borderRadius: borderRadius,
);

const OutlineInputBorder redOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AbiliaColors.red),
  borderRadius: borderRadius,
);

const OutlineInputBorder transparentOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.transparent),
  borderRadius: borderRadius,
);

const ButtonThemeData baseButtonTheme = ButtonThemeData(
  height: 64,
  minWidth: 48,
  shape: ligthShapeBorder,
);

ButtonThemeData redButtonThemeData = baseButtonTheme.copyWith(
  minWidth: double.infinity,
  buttonColor: AbiliaColors.red,
  disabledColor: AbiliaColors.red40,
  highlightColor: AbiliaColors.red120,
);

ButtonThemeData greenButtonThemeData = baseButtonTheme.copyWith(
  minWidth: double.infinity,
  buttonColor: AbiliaColors.green,
  disabledColor: AbiliaColors.green40,
  highlightColor: AbiliaColors.green120,
);

const ButtonThemeData checkButtonThemeData = ButtonThemeData(
  height: 48,
  minWidth: 111,
  shape: darkShapeBorder,
  buttonColor: AbiliaColors.green,
  disabledColor: AbiliaColors.green40,
  highlightColor: AbiliaColors.green120,
);

ButtonThemeData uncheckButtonThemeData = checkButtonThemeData.copyWith(
  buttonColor: AbiliaColors.transparentBlack20,
  highlightColor: AbiliaColors.transparentBlack40,
);

ButtonThemeData actionButtonThemeData = baseButtonTheme.copyWith(
  disabledColor: Colors.transparent,
  height: 48,
);

ButtonThemeData lightActionButtonThemeData = actionButtonThemeData.copyWith(
  buttonColor: AbiliaColors.white,
  highlightColor: AbiliaColors.transparentWhite40,
  disabledColor: Colors.transparent,
  shape: ligthShapeBorder,
);

ButtonThemeData darkActionButtonThemeData = baseButtonTheme.copyWith(
  buttonColor: AbiliaColors.black,
  highlightColor: AbiliaColors.transparentBlack40,
  shape: darkShapeBorder,
);

ThemeData darkButtonTheme = abiliaTheme.copyWith(
  buttonTheme: darkActionButtonThemeData,
  textTheme: abiliaTheme.textTheme.copyWith(
      button: abiliaTheme.textTheme.button.copyWith(color: AbiliaColors.black)),
  buttonColor: AbiliaColors.transparentBlack20,
);

ThemeData lightButtonTheme = abiliaTheme.copyWith(
  buttonTheme: lightActionButtonThemeData,
  buttonColor: AbiliaColors.transparentWhite20,
  disabledColor: AbiliaColors.transparentWhite40,
);

ThemeData redButtonTheme = abiliaTheme.copyWith(
  buttonTheme: redButtonThemeData,
  buttonColor: AbiliaColors.red,
  textTheme: abiliaTheme.textTheme.copyWith(
    button: abiliaTheme.textTheme.subtitle1.copyWith(
      color: AbiliaColors.white,
    ),
  ),
);

ThemeData greenButtonTheme = abiliaTheme.copyWith(
  buttonTheme: greenButtonThemeData,
  buttonColor: AbiliaColors.green,
  textTheme: abiliaTheme.textTheme.copyWith(
    button: abiliaTheme.textTheme.subtitle1.copyWith(
      color: AbiliaColors.white,
    ),
  ),
);

ThemeData nowButtonTheme = redButtonTheme.copyWith(
  buttonTheme: redButtonThemeData.copyWith(
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: AbiliaColors.red120),
      borderRadius: borderRadius,
    ),
  ),
  buttonColor: AbiliaColors.red,
  disabledColor: AbiliaColors.red40,
  highlightColor: AbiliaColors.red120,
  textTheme: abiliaTextTheme.copyWith(
    button: abiliaTextTheme.button.copyWith(color: AbiliaColors.white),
  ),
);

ThemeData alreadySelectedChoiceButtonTheme = abiliaTheme.copyWith(
    buttonTheme: lightActionButtonThemeData,
    buttonColor: AbiliaColors.black,
    textTheme: abiliaTextTheme.copyWith(
        button: abiliaTextTheme.button.copyWith(color: AbiliaColors.white)));

ThemeData availableToSelectButtonTheme = abiliaTheme.copyWith(
    buttonTheme: lightActionButtonThemeData,
    buttonColor: AbiliaColors.white,
    textTheme: abiliaTextTheme.copyWith(
        button: abiliaTextTheme.button.copyWith(color: AbiliaColors.black)));

ThemeData bottomNavigationBarTheme = abiliaTheme.copyWith(
  buttonTheme: lightActionButtonThemeData.copyWith(shape: ligthShapeBorder),
  buttonColor: AbiliaColors.transparentWhite20,
  iconTheme: IconThemeData(size: defaultIconSize),
);

TextTheme abiliaTextTheme = TextTheme(
  headline1: baseTextStyle.copyWith(
    fontSize: 96.0,
    fontWeight: light,
    height: 1.0,
  ),
  headline2: baseTextStyle.copyWith(
    fontSize: 60.0,
    fontWeight: light,
    height: 72.0 / 60.0,
  ),
  headline3: baseTextStyle.copyWith(
    fontSize: 48.0,
    fontWeight: regular,
    height: 56.0 / 48.0,
  ),
  headline4: baseTextStyle.copyWith(
    fontSize: 34.0,
    fontWeight: regular,
    height: 1.0,
  ),
  headline5: baseTextStyle.copyWith(
    fontSize: 24.0,
    fontWeight: regular,
    height: 1.0,
  ),
  headline6: baseTextStyle.copyWith(
    fontSize: 20.0,
    fontWeight: medium,
    height: 1.0,
  ),
  subtitle1: baseTextStyle.copyWith(
    fontSize: 16.0,
    fontWeight: medium,
    height: 24.0 / 16.0,
  ),
  subtitle2: baseTextStyle.copyWith(
    fontSize: 14.0,
    fontWeight: medium,
    height: 20.0 / 14.0,
  ),
  bodyText1: baseTextStyle.copyWith(
    fontSize: 16.0,
    fontWeight: regular,
    height: 28.0 / 16.0,
  ),
  bodyText2: baseTextStyle.copyWith(
    fontSize: 14.0,
    fontWeight: regular,
    height: 20.0 / 14.0,
  ),
  caption: baseTextStyle.copyWith(
    fontSize: 12.0,
    fontWeight: regular,
    height: 16.0 / 12.0,
  ),
  button: baseTextStyle.copyWith(
    color: AbiliaColors.white,
    fontSize: 14.0,
    fontWeight: medium,
    height: 1.0,
  ),
  overline: baseTextStyle.copyWith(
    fontSize: 10.0,
    fontWeight: medium,
    height: 16.0 / 10.0,
  ),
);

const TextStyle baseTextStyle = TextStyle(
  fontFamily: 'Roboto',
  color: AbiliaColors.black,
  fontStyle: FontStyle.normal,
  letterSpacing: 0.0,
);

const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
