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
    errorStyle: TextStyle(height: 0, fontSize: 0),
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

ThemeData actionButtonTheme(BuildContext context) => Theme.of(context).copyWith(
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
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
          textTheme: ButtonTextTheme.primary),
    );

ThemeData nowButtonTheme(BuildContext context) =>
    actionButtonTheme(context).copyWith(
      buttonColor: AbiliaColors.red,
      disabledColor: AbiliaColors.red[40],
      highlightColor: AbiliaColors.red[120],
    );

ThemeData showHideButtonTheme(BuildContext context) =>
    actionButtonTheme(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
            button: Theme.of(context)
                .textTheme
                .button
                .copyWith(color: AbiliaColors.black[75])));

ThemeData menuButtonTheme(BuildContext context) => actionButtonTheme(context)
    .copyWith(buttonColor: AbiliaColors.transparantWhite[20]);

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
          fontSize: 16.0, fontWeight: medium, height: 24.0 / 16.0),
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
          fontSize: 14.0, fontWeight: medium, color: AbiliaColors.white),
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

Map<int, ThemeData> weekDayTheme(BuildContext context) => {
      DateTime.monday: _dayTheme(context, AbiliaColors.green),
      DateTime.tuesday: _dayTheme(context, AbiliaColors.blue),
      DateTime.wednesday:
          _dayTheme(context, AbiliaColors.white, textColor: AbiliaColors.black),
      DateTime.thursday: _dayTheme(context, AbiliaColors.brown),
      DateTime.friday: _dayTheme(context, AbiliaColors.yellow),
      DateTime.saturday: _dayTheme(context, AbiliaColors.pink),
      DateTime.sunday: _dayTheme(context, AbiliaColors.red),
    };

ThemeData _dayTheme(BuildContext context, MaterialColor color,
        {MaterialColor textColor = AbiliaColors.white}) =>
    Theme.of(context).copyWith(
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              color: color,
            ),
        scaffoldBackgroundColor: color[20],
        textTheme: abiliaTextTheme.copyWith(
            title: abiliaTextTheme.title.copyWith(color: textColor),
            subhead: abiliaTextTheme.subhead.copyWith(color: textColor)));
