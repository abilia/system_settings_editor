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

  
  

}
