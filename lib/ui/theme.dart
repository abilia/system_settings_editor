import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData get abiliaTheme => ThemeData(
      scaffoldBackgroundColor: AbiliaColors.white[110],
      primaryColor: AbiliaColors.black,
      accentColor: AbiliaColors.red,
      fontFamily: 'Roboto',
      inputDecorationTheme: inputDecorationTheme,
      textTheme: textTheme,
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
        margin: EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    );

InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AbiliaColors.white),
      borderRadius: borderRadius,
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AbiliaColors.white),
      borderRadius: borderRadius,
    ),
    errorBorder: redOutlineInputBorder,
    focusedErrorBorder: redOutlineInputBorder,
    filled: true,
    // Unfortunatly, can't use the validation without showing some error text, set the font size 0
    errorStyle: TextStyle(height: 0, fontSize: 0),
    fillColor: AbiliaColors.white);

BorderRadius get borderRadius => BorderRadius.circular(12);

OutlineInputBorder get redOutlineInputBorder => OutlineInputBorder(
      borderSide: BorderSide(color: AbiliaColors.red),
      borderRadius: borderRadius,
    );

ButtonThemeData get baseButtonTheme => ButtonThemeData(
      height: 64,
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      buttonColor: AbiliaColors.red,
      textTheme: ButtonTextTheme.primary,
      disabledColor: AbiliaColors.red[40],
      highlightColor: AbiliaColors.red[120],
    );

ThemeData actionButtonTheme(BuildContext context) => Theme.of(context).copyWith(
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          height: 48,
          minWidth: 48,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
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

AppBarTheme get appBarTheme => AppBarTheme(color: AbiliaColors.black[90]);

TextTheme get textTheme => TextTheme(
      body1: TextStyle(
        fontSize: 16,
        letterSpacing: .5,
        height: 28 / 16,
        fontWeight: FontWeight.w500,
        color: AbiliaColors.black[75],
      ),
      button: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: AbiliaColors.white,
      ),
      subtitle: TextStyle(
        fontSize: 16,
        letterSpacing: .15,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
        color: AbiliaColors.black,
      ),
    );

Map<int, ThemeData> weekDayTheme(BuildContext context) => {
      DateTime.monday: _dayTheme(context, AbiliaColors.green),
      DateTime.tuesday: _dayTheme(context, AbiliaColors.blue),
      DateTime.wednesday:
          _dayTheme(context, Colors.grey /* AbiliaColors.white */),
      DateTime.thursday: _dayTheme(context, AbiliaColors.brown),
      DateTime.friday: _dayTheme(context, AbiliaColors.yellow),
      DateTime.saturday: _dayTheme(context, AbiliaColors.pink),
      DateTime.sunday: _dayTheme(context, AbiliaColors.red),
    };

ThemeData _dayTheme(BuildContext context, MaterialColor color) =>
    Theme.of(context).copyWith(
      appBarTheme: Theme.of(context).appBarTheme.copyWith(color: color),
      scaffoldBackgroundColor: color[20],
    );
