import 'package:flutter/material.dart';

class AbiliaColors {
  static const MaterialColor red = MaterialColor(
    _redPrimaryValue,
    <int, Color>{
        0: Color(0xFFFAE8EC),
       20: Color(0xFFF0BBC7),
       40: Color(0xFFE68EA2),
       60: Color(0xFFF34863),
       80: Color(0xFFD33458),
      100: Color(_redPrimaryValue),
      120: Color(0xFFA6062A),
      140: Color(0xFF810521),
      160: Color(0xFF5C0418),
      180: Color(0xFF38020E),
      200: Color(0xFF130105),
    },
  );
  static const int _redPrimaryValue = 0xFFCA0733;

  static const MaterialColor black = MaterialColor(
    _blackPrimaryValue,
    <int, Color>{
       60: Color(0xFF666666),
       75: Color(0xFF414141),
       80: Color(0xFF333333),
       90: Color(0xFF191919),
      100: Color(_blackPrimaryValue),
    },
  );
  static const int _blackPrimaryValue = 0xFF000000;

  static const MaterialColor white = MaterialColor(
    _whitePrimaryValue,
    <int, Color>{
      100: Color(_whitePrimaryValue),
      110: Color(0xFFE6E6E6),
      120: Color(0xFFCCCCCC),
      135: Color(0xFFA5A5A5),
      140: Color(0xFF999999),
      150: Color(0xFF7F7F7F),
    },
  );
  static const int _whitePrimaryValue = 0xFFFFFFFF;

  static const MaterialColor orange = MaterialColor(
    _orangePrimaryValue,
    <int, Color>{
      0: Color(0xFFFDF5E8),
      20: Color(0xFFFBE1BB),
      40: Color(0xFFF9CE8E),
      60: Color(0xFFF6BA61),
      80: Color(0xFFF4A734),
      100: Color(_orangePrimaryValue),
      120: Color(0xFFC77A06),
      140: Color(0xFF9B5F05),
      160: Color(0xFF6E4404),
      180: Color(0xFF422902),
      200: Color(0xFF160E01),
    },
  );
  static const int _orangePrimaryValue = 0xFFF29407;
}
