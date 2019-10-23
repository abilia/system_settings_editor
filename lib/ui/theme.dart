import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';

final ThemeData abiliaTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFE6E6E6),
    primaryColor: Colors.black,
    accentColor: Colors.white,
    fontFamily: 'Roboto',
    textTheme:
        TextTheme(button: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
    buttonTheme: ButtonThemeData(
        buttonColor: RED,
        shape: RoundedRectangleBorder(),
        textTheme: ButtonTextTheme.primary));
