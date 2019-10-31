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
      cursorColor: AbiliaColors.black,
      textSelectionHandleColor: AbiliaColors.black,
      appBarTheme: appBarTheme,
      errorColor: AbiliaColors.red,
      textSelectionColor: AbiliaColors.white[120],
      bottomAppBarTheme: bottomAppBarTheme,
      cardTheme: CardTheme(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
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
    errorStyle: TextStyle(
        fontSize: double
            .minPositive), // Unfortunatly, can't use the validation without showing some error text, set the font size to super small and it is almost unnoticeable
    fillColor: AbiliaColors.white);

BorderRadius get borderRadius => BorderRadius.circular(12);

OutlineInputBorder get redOutlineInputBorder => OutlineInputBorder(
      borderSide: BorderSide(color: AbiliaColors.red),
      borderRadius: borderRadius,
    );

ButtonThemeData get baseButtonTheme => ButtonThemeData(
      height: 64,
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      buttonColor: AbiliaColors.red,
      disabledColor: AbiliaColors.red[40],
      highlightColor: AbiliaColors.red[120],
    );

ButtonThemeData get actionButtonTheme => ButtonThemeData(
    height: 48,
    minWidth: 48,
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius,
    ),
    buttonColor: AbiliaColors.active,
    disabledColor: Colors.transparent,
    highlightColor: AbiliaColors.pressed,
    textTheme: ButtonTextTheme.primary);

ButtonThemeData get nowButtonTheme => actionButtonTheme.copyWith(
      buttonColor: AbiliaColors.red,
      disabledColor: AbiliaColors.red[40],
      highlightColor: AbiliaColors.red[120],
    );

ButtonThemeData get showHideButtonTheme =>
    actionButtonTheme.copyWith(textTheme: ButtonTextTheme.normal);

BottomAppBarTheme get bottomAppBarTheme => BottomAppBarTheme(
      color: AbiliaColors.black,
    );

AppBarTheme get appBarTheme => AppBarTheme(color: AbiliaColors.black[75]);

TextTheme get textTheme => TextTheme(
      body1: TextStyle( fontSize: 16, letterSpacing: .5, height: 28/16, fontWeight: FontWeight.w500, color: AbiliaColors.black[75]),
      button:  TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
      subtitle: TextStyle(fontSize: 16, letterSpacing: .15, height: 24/16, fontWeight: FontWeight.w500, color: AbiliaColors.black),
    );

Map<int, ThemeData> weekDayTheme(BuildContext context) => {
      DateTime.monday: _dayTheme(context, AbiliaColors.green),
      DateTime.tuesday: _dayTheme(context, AbiliaColors.blue),
      DateTime.wednesday:
          _dayTheme(context, /*AbiliaColors.white*/Colors.grey),
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
