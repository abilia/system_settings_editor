import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData get abiliaTheme => ThemeData(
      scaffoldBackgroundColor: AbiliaColors.white[110],
      primaryColor: AbiliaColors.black,
      accentColor: AbiliaColors.red,
      fontFamily: 'Roboto',
      inputDecorationTheme: inputDecorationTheme,
      textTheme: abiliaTextTheme,
      buttonTheme: baseButtonTheme,
      buttonColor: AbiliaColors.transparantBlack[20],
      highlightColor: AbiliaColors.transparantBlack[40],
      cursorColor: AbiliaColors.black,
      textSelectionHandleColor: AbiliaColors.black,
      appBarTheme: appBarTheme,
      disabledColor: AbiliaColors.red[40],
      errorColor: AbiliaColors.red,
      textSelectionColor: AbiliaColors.white[120],
      bottomAppBarTheme: bottomAppBarTheme,
      cardTheme: CardTheme(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    );

InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16),
    focusedBorder: inputBorder,
    enabledBorder: inputBorder,
    errorBorder: redOutlineInputBorder,
    focusedErrorBorder: redOutlineInputBorder,
    filled: true,
    // Unfortunatly, can't use the validation without showing some error text, set the font size 0
    errorStyle: TextStyle(height: 0),
    fillColor: AbiliaColors.white);

BorderRadius get borderRadius => BorderRadius.circular(12);

InputBorder get inputBorder => OutlineInputBorder(
      borderSide: BorderSide(color: AbiliaColors.transparantBlack[20]),
      borderRadius: borderRadius,
    );

OutlineInputBorder get redOutlineInputBorder => OutlineInputBorder(
      borderSide: BorderSide(color: AbiliaColors.red),
      borderRadius: borderRadius,
    );

ButtonThemeData get baseButtonTheme => ButtonThemeData(
      height: 64,
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      buttonColor: AbiliaColors.red,
      disabledColor: AbiliaColors.red[40],
      highlightColor: AbiliaColors.red[120],
    );

ButtonThemeData get greenButtonTheme => ButtonThemeData(
      height: 48,
      minWidth: 188,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      buttonColor: AbiliaColors.green,
      disabledColor: AbiliaColors.green[40],
      highlightColor: AbiliaColors.green[120],
    );

ButtonThemeData get actionButtonTheme => baseButtonTheme.copyWith(
      height: 48,
      minWidth: 48,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          width: 1,
          color: AbiliaColors.transparantBlack[20],
        ),
      ),
      buttonColor: AbiliaColors.transparantBlack[20],
      disabledColor: Colors.transparent,
      highlightColor: AbiliaColors.transparantBlack[40],
      textTheme: ButtonTextTheme.primary,
    );

ThemeData get nowButtonTheme => abiliaTheme.copyWith(
    buttonTheme: actionButtonTheme,
    buttonColor: AbiliaColors.red,
    disabledColor: AbiliaColors.red[40],
    highlightColor: AbiliaColors.red[120],
    textTheme: abiliaTextTheme.copyWith(
        button: abiliaTextTheme.button.copyWith(color: AbiliaColors.white)));

ThemeData get alreadySelectedChoiceButtonTheme => abiliaTheme.copyWith(
    buttonTheme: actionButtonTheme,
    buttonColor: AbiliaColors.black,
    textTheme: abiliaTextTheme.copyWith(
        button: abiliaTextTheme.button.copyWith(color: AbiliaColors.white)));

ThemeData get availableToSelectButtonTheme => abiliaTheme.copyWith(
    buttonTheme: actionButtonTheme,
    buttonColor: AbiliaColors.white,
    textTheme: abiliaTextTheme.copyWith(
        button: abiliaTextTheme.button.copyWith(color: AbiliaColors.black)));

ThemeData get showHideButtonTheme => abiliaTheme.copyWith(
    buttonTheme: actionButtonTheme,
    textTheme: abiliaTheme.textTheme.copyWith(
        button: abiliaTheme.textTheme.button
            .copyWith(color: AbiliaColors.black[75])));

ThemeData get menuButtonTheme => abiliaTheme.copyWith(
    buttonTheme: actionButtonTheme,
    buttonColor: AbiliaColors.transparantWhite[20]);

BottomAppBarTheme get bottomAppBarTheme =>
    BottomAppBarTheme(color: AbiliaColors.black[80]);

AppBarTheme get appBarTheme => AppBarTheme(color: AbiliaColors.black[80]);

TextTheme get abiliaTextTheme => TextTheme(
      display4: baseTextStyle.copyWith(
        fontSize: 96.0,
        fontWeight: light,
      ),
      display3: baseTextStyle.copyWith(
        fontSize: 60.0,
        fontWeight: light,
        height: 72.0 / 60.0,
      ),
      display2: baseTextStyle.copyWith(
        fontSize: 48.0,
        fontWeight: regular,
        height: 56.0 / 48.0,
      ),
      display1: baseTextStyle.copyWith(
        fontSize: 34.0,
        fontWeight: regular,
      ),
      headline: baseTextStyle.copyWith(
        fontSize: 24.0,
        fontWeight: regular,
      ),
      title: baseTextStyle.copyWith(
        fontSize: 20.0,
        fontWeight: medium,
      ),
      subhead: baseTextStyle.copyWith(
        fontSize: 16.0,
        fontWeight: medium,
        height: 24.0 / 16.0,
      ),
      body2: baseTextStyle.copyWith(
        fontSize: 16.0,
        height: 28.0 / 16.0,
        fontWeight: regular,
      ),
      body1: baseTextStyle.copyWith(
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
      subtitle: baseTextStyle.copyWith(
        fontSize: 14.0,
        height: 20.0 / 14.0,
        fontWeight: medium,
      ),
      overline: baseTextStyle.copyWith(
        fontSize: 10.0,
        height: 16.0 / 10.0,
        fontWeight: medium,
      ),
    );

TextStyle baseTextStyle = const TextStyle(
  fontFamily: 'Roboto',
  color: AbiliaColors.black,
  fontStyle: FontStyle.normal,
  letterSpacing: 0.0,
);

FontWeight get light => FontWeight.w300;
FontWeight get regular => FontWeight.w400;
FontWeight get medium => FontWeight.w500;

Map<int, ThemeData> get weekDayTheme => {
      DateTime.monday: _dayTheme(AbiliaColors.green,
          textColor: AbiliaColors.black, primaryColor: AbiliaColors.white),
      DateTime.tuesday: _dayTheme(AbiliaColors.darkBlue),
      DateTime.wednesday:
          _dayTheme(AbiliaColors.white, textColor: AbiliaColors.black),
      DateTime.thursday: _dayTheme(AbiliaColors.brown),
      DateTime.friday: _dayTheme(AbiliaColors.yellow,
          textColor: AbiliaColors.black, primaryColor: AbiliaColors.white),
      DateTime.saturday:
          _dayTheme(AbiliaColors.pink, textColor: AbiliaColors.black),
      DateTime.sunday: _dayTheme(AbiliaColors.red),
    };

Map<int, ThemeData> allDayTheme() => {
      DateTime.monday: _dayTheme(AbiliaColors.green,
          textColor: AbiliaColors.black,
          primaryColor: AbiliaColors.white,
          scaffoldShade: 120),
      DateTime.tuesday: _dayTheme(AbiliaColors.darkBlue, scaffoldShade: 120),
      DateTime.wednesday: _dayTheme(AbiliaColors.white,
          textColor: AbiliaColors.black, scaffoldShade: 120),
      DateTime.thursday: _dayTheme(AbiliaColors.brown, scaffoldShade: 120),
      DateTime.friday: _dayTheme(AbiliaColors.yellow,
          textColor: AbiliaColors.black,
          primaryColor: AbiliaColors.white,
          scaffoldShade: 120),
      DateTime.saturday: _dayTheme(AbiliaColors.pink,
          textColor: AbiliaColors.black, scaffoldShade: 120),
      DateTime.sunday: _dayTheme(AbiliaColors.red, scaffoldShade: 120),
    };

ThemeData _dayTheme(MaterialColor color,
        {MaterialColor textColor = AbiliaColors.white,
        MaterialColor primaryColor = AbiliaColors.black,
        int scaffoldShade = 20}) =>
    abiliaTheme.copyWith(
        primaryColor: primaryColor,
        appBarTheme: abiliaTheme.appBarTheme.copyWith(
          color: color,
        ),
        scaffoldBackgroundColor: color[scaffoldShade],
        textTheme: abiliaTextTheme.copyWith(
          title: abiliaTextTheme.title.copyWith(color: textColor),
          button: abiliaTextTheme.button.copyWith(color: textColor),
          subhead: abiliaTextTheme.subhead.copyWith(color: textColor),
        ));

Map<int, Brightness> getThemeAppBarBrightness() => {
      DateTime.monday: Brightness.light,
      DateTime.tuesday: Brightness.dark,
      DateTime.wednesday: Brightness.light,
      DateTime.thursday: Brightness.dark,
      DateTime.friday: Brightness.light,
      DateTime.saturday: Brightness.light,
      DateTime.sunday: Brightness.dark,
    };
