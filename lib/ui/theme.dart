import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';

ThemeData get abiliaTheme => ThemeData(
    scaffoldBackgroundColor: AbiliaColors.white[110],
    primaryColor: AbiliaColors.black,
    accentColor: AbiliaColors.red,
    fontFamily: 'Roboto',
    inputDecorationTheme: inputDecorationTheme,
    textTheme: TextTheme(
      body1: TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w400),
      button: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
      
    ),
    buttonTheme: baseButtonTheme,
    disabledColor: AbiliaColors.red[40],
    cursorColor: AbiliaColors.black,
    textSelectionHandleColor: AbiliaColors.black,
    errorColor: AbiliaColors.red,
    buttonColor: AbiliaColors.white[135],
    textSelectionColor: AbiliaColors.white[120]);

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
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AbiliaColors.red),
      borderRadius: borderRadius,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AbiliaColors.red),
      borderRadius: borderRadius,
    ),
    filled: true,
    errorStyle: TextStyle(fontSize: 0.001), // Unfortunatly, can't use the validation without showing some error text, set the font size to super small and it is almost unnoticeable
    fillColor: AbiliaColors.white);

BorderRadius get borderRadius => BorderRadius.circular(12);

ButtonThemeData get baseButtonTheme => ButtonThemeData(
      height: 64,
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      textTheme: ButtonTextTheme.primary,
    );
