import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData abiliaTheme = ThemeData(
  scaffoldBackgroundColor: AbiliaColors.white110,
  primaryColor: AbiliaColors.black,
  accentColor: AbiliaColors.black,
  unselectedWidgetColor: AbiliaColors.white120,
  fontFamily: 'Roboto',
  inputDecorationTheme: inputDecorationTheme,
  textTheme: abiliaTextTheme,
  buttonTheme: baseButtonTheme,
  buttonColor: AbiliaColors.transparentBlack20,
  highlightColor: AbiliaColors.transparentBlack40,
  cursorColor: AbiliaColors.black,
  textSelectionHandleColor: AbiliaColors.black,
  appBarTheme: AppBarTheme(color: AbiliaColors.black80),
  disabledColor: AbiliaColors.red40,
  errorColor: AbiliaColors.red,
  textSelectionColor: AbiliaColors.white120,
  bottomAppBarTheme: BottomAppBarTheme(color: AbiliaColors.black80),
  cupertinoOverrideTheme: CupertinoThemeData(primaryColor: AbiliaColors.black),
  toggleableActiveColor: AbiliaColors.green,
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
const BorderRadius onlyLeft = BorderRadius.horizontal(left: radius);
const BorderRadius onlyRight = BorderRadius.horizontal(right: radius);
const BorderSide borderSide =
    BorderSide(color: AbiliaColors.white120, width: 1.0);
const Border currentActivityBorder =
    Border.fromBorderSide(BorderSide(color: AbiliaColors.red, width: 2.0));
const border = Border.fromBorderSide(borderSide);
const BoxDecoration borderDecoration = BoxDecoration(
  borderRadius: borderRadius,
  border: border,
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
const inactiveGrey = AbiliaColors.white110;
const BoxDecoration inactiveBoxDecoration = BoxDecoration(
  color: inactiveGrey,
  borderRadius: borderRadius,
  border: border,
);
BoxDecoration getBoxDecoration(bool current, bool inactive) => inactive
    ? inactiveBoxDecoration
    : current ? currentBoxDecoration : whiteBoxDecoration;

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
  shape: RoundedRectangleBorder(borderRadius: borderRadius),
);

ButtonThemeData redButtonThemeData = baseButtonTheme.copyWith(
  minWidth: double.infinity,
  buttonColor: AbiliaColors.red,
  disabledColor: AbiliaColors.red40,
  highlightColor: AbiliaColors.red120,
);

const ButtonThemeData checkButtonThemeData = ButtonThemeData(
  height: 48,
  minWidth: 111,
  shape: OutlineInputBorder(
    borderSide: BorderSide(
      color: AbiliaColors.transparentBlack15,
      width: 1,
    ),
    borderRadius: borderRadius,
  ),
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
  buttonColor: AbiliaColors.transparentWhite20,
  highlightColor: AbiliaColors.transparentWhite40,
  disabledColor: Colors.transparent,
  shape: OutlineInputBorder(
    borderSide: BorderSide(
      color: AbiliaColors.transparentWhite15,
      width: 1,
    ),
    borderRadius: borderRadius,
  ),
);

ButtonThemeData darkActionButtonThemeData = baseButtonTheme.copyWith(
  buttonColor: AbiliaColors.transparentBlack20,
  highlightColor: AbiliaColors.transparentBlack40,
  shape: OutlineInputBorder(
    borderSide: BorderSide(
      color: AbiliaColors.transparentBlack15,
      width: 1,
    ),
    borderRadius: borderRadius,
  ),
);

ThemeData darkButtonTheme = abiliaTheme.copyWith(
  buttonTheme: darkActionButtonThemeData,
  textTheme: abiliaTheme.textTheme.copyWith(
      button:
          abiliaTheme.textTheme.button.copyWith(color: AbiliaColors.black75)),
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

ThemeData nowButtonTheme = redButtonTheme.copyWith(
  buttonTheme: redButtonThemeData.copyWith(
    shape: OutlineInputBorder(
      borderSide: BorderSide(
        color: AbiliaColors.red120,
        width: 1,
      ),
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

ThemeData menuButtonTheme = abiliaTheme.copyWith(
  buttonTheme: lightActionButtonThemeData.copyWith(
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: BorderSide(
        width: 1,
        color: AbiliaColors.transparentWhite15,
      ),
    ),
  ),
  buttonColor: AbiliaColors.transparentWhite20,
);

ThemeData addButtonTheme = abiliaTheme.copyWith(
  buttonTheme: lightActionButtonThemeData.copyWith(
    shape: const RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: BorderSide(
        width: 1,
        color: AbiliaColors.transparentBlack15,
      ),
    ),
  ),
  buttonColor: AbiliaColors.white,
  textTheme: abiliaTextTheme.copyWith(
    button: abiliaTextTheme.button.copyWith(color: AbiliaColors.black),
  ),
);

TextTheme abiliaTextTheme = TextTheme(
  headline1: baseTextStyle.copyWith(
    fontSize: 96.0,
    fontWeight: light,
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
  ),
  headline5: baseTextStyle.copyWith(
    fontSize: 24.0,
    fontWeight: regular,
  ),
  headline6: baseTextStyle.copyWith(
    fontSize: 20.0,
    fontWeight: medium,
  ),
  subtitle1: baseTextStyle.copyWith(
    fontSize: 16.0,
    fontWeight: medium,
    height: 24.0 / 16.0,
  ),
  subtitle2: baseTextStyle.copyWith(
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: medium,
  ),
  bodyText1: baseTextStyle.copyWith(
    fontSize: 16.0,
    height: 28.0 / 16.0,
    fontWeight: regular,
  ),
  bodyText2: baseTextStyle.copyWith(
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: regular,
  ),
  caption: baseTextStyle.copyWith(
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: regular,
  ),
  button: baseTextStyle.copyWith(
    fontSize: 14.0,
    fontWeight: medium,
    color: AbiliaColors.white,
  ),
  overline: baseTextStyle.copyWith(
    fontSize: 10.0,
    height: 16.0 / 10.0,
    fontWeight: medium,
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

const Map<int, MaterialColor> weekDayColor = {
  DateTime.monday: AbiliaColors.green,
  DateTime.tuesday: AbiliaColors.darkBlue,
  DateTime.wednesday: AbiliaColors.white,
  DateTime.thursday: AbiliaColors.brown,
  DateTime.friday: AbiliaColors.yellow,
  DateTime.saturday: AbiliaColors.pink,
  DateTime.sunday: AbiliaColors.red,
};

Map<int, ThemeData> weekDayTheme = {
  DateTime.monday: _dayTheme(
    darkButtonTheme,
    weekDayColor[DateTime.monday],
    textColor: AbiliaColors.black,
    primaryColor: AbiliaColors.white,
  ),
  DateTime.tuesday: _dayTheme(
    lightButtonTheme,
    weekDayColor[DateTime.tuesday],
    appBarBrightness: Brightness.dark,
  ),
  DateTime.wednesday: _dayTheme(
    darkButtonTheme,
    weekDayColor[DateTime.wednesday],
    textColor: AbiliaColors.black,
  ),
  DateTime.thursday: _dayTheme(
    lightButtonTheme,
    weekDayColor[DateTime.thursday],
    appBarBrightness: Brightness.dark,
  ),
  DateTime.friday: _dayTheme(
    darkButtonTheme,
    weekDayColor[DateTime.friday],
    textColor: AbiliaColors.black,
    primaryColor: AbiliaColors.white,
  ),
  DateTime.saturday: _dayTheme(
    darkButtonTheme,
    weekDayColor[DateTime.saturday],
    textColor: AbiliaColors.black,
  ),
  DateTime.sunday: _dayTheme(
    lightButtonTheme,
    weekDayColor[DateTime.sunday],
    appBarBrightness: Brightness.dark,
  ),
};

ThemeData _dayTheme(
  ThemeData themeData,
  MaterialColor color, {
  MaterialColor textColor = AbiliaColors.white,
  MaterialColor primaryColor = AbiliaColors.black,
  Brightness appBarBrightness = Brightness.light,
}) =>
    themeData.copyWith(
      primaryColor: primaryColor,
      accentColor: textColor,
      appBarTheme: abiliaTheme.appBarTheme.copyWith(
        color: color,
        brightness: appBarBrightness,
      ),
      scaffoldBackgroundColor: AbiliaColors.white110,
      textTheme: abiliaTextTheme.copyWith(
        headline6: abiliaTextTheme.headline6.copyWith(color: textColor),
        button: abiliaTextTheme.button.copyWith(color: textColor),
        subtitle1: abiliaTextTheme.subtitle1.copyWith(color: textColor),
      ),
    );
