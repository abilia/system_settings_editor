import 'package:flutter/material.dart';

class AbiliaColors {
  AbiliaColors._();

  static const MaterialColor peach = MaterialColor(
    _peachAccentValue,
    <int, Color>{
      100: peach100,
      200: peach200,
      300: peach300,
      400: peach400,
      500: peach500,
    },
  );

  static const int _peachAccentValue = 0xFFFFD8CC;
  static const peach100 = Color(_peachAccentValue);
  static const peach200 = Color(0xFFFD9F81);
  static const peach300 = Color(0xFFF97B53);
  static const peach400 = Color(0xFFF05828);
  static const peach500 = Color(0xFFBD390F);
  static const peach600 = Color(0xFFFF250D);

  static const MaterialColor yellow =
      MaterialColor(_yellowAccentValue, <int, Color>{
    100: yellow100,
    200: yellow200,
    300: yellow300,
    400: yellow400,
    500: yellow500,
  });

  static const int _yellowAccentValue = 0xFFFFF0A4;
  static const yellow100 = Color(_yellowAccentValue);
  static const yellow200 = Color(0xFFFFEA7B);
  static const yellow300 = Color(0xFFFFE146);
  static const yellow400 = Color(0xFFF8D51F);
  static const yellow500 = Color(0xFFF1CB00);

  static const MaterialColor greyscale =
      MaterialColor(_greyscaleValue, <int, Color>{
    0: greyscale000,
    50: greyscale50,
    100: greyscale100,
    200: greyscale200,
    300: greyscale300,
    400: greyscale400,
    500: greyscale500,
    600: greyscale600,
    700: greyscale700,
    800: greyscale800,
    900: greyscale900,
    1000: greyscale1000,
  });

  static const int _greyscaleValue = 0xFFFFFFFF;
  static const greyscale000 = Color(_greyscaleValue);
  static const greyscale50 = Color(0xFFF9F9FB);
  static const greyscale100 = Color(0xFFF2F3F7);
  static const greyscale200 = Color(0xFFE8E9ED);
  static const greyscale300 = Color(0xFFD9DADE);
  static const greyscale400 = Color(0xFFC8C9CC);
  static const greyscale500 = Color(0xFFBBBCBF);
  static const greyscale600 = Color(0xFF646466);
  static const greyscale700 = Color(0xFF575859);
  static const greyscale800 = Color(0xFF4B4B4D);
  static const greyscale900 = Color(0xFF252626);
  static const greyscale1000 = Color(0xFF111212);

  static const MaterialColor primary =
      MaterialColor(_primaryValue, <int, Color>{
    100: primary100,
    200: primary200,
    300: primary300,
    400: primary400,
    500: primary500,
    600: primary600,
    700: primary700,
  });

  static const int _primaryValue = 0xFFF2F3FC;
  static const primary100 = Color(_primaryValue);
  static const primary200 = Color(0xFFD5D8F6);
  static const primary300 = Color(0xFFC9CCF3);
  static const primary400 = Color(0xFFB4B9EE);
  static const primary500 = Color(0xFF4E5AD9);
  static const primary600 = Color(0xFF454FBF);
  static const primary700 = Color(0xFF3C45A6);

  static const MaterialColor secondary =
      MaterialColor(_secondaryValue, <int, Color>{
    100: secondary100,
    200: secondary200,
    300: secondary300,
    400: secondary400,
    500: secondary500,
    600: secondary600,
    700: secondary700,
  });

  static const int _secondaryValue = 0xFFD9F9F1;
  static const secondary100 = Color(_secondaryValue);
  static const secondary200 = Color(0xFFC5F0E6);
  static const secondary300 = Color(0xFFB6E5DA);
  static const secondary400 = Color(0xFF027B5E);
  static const secondary500 = Color(0xFF027B5E);
  static const secondary600 = Color(0xFF016C53);
  static const secondary700 = Color(0xFF005F48);
}

class FontColors {
  FontColors._();

  static const Color primary = Color(0xFF252626);
  static const Color secondary = Color(0xFF575859);
}
