import 'package:flutter/material.dart';

const int _abiliaWhitePrimaryValue = 0xFFFFFFFF;
const abiliaWhite150 = Color(0xFF7F7F7F),
    abiliaWhite140 = Color(0xFF999999),
    abiliaWhite135 = Color(0xFFA5A5A5),
    abiliaWhite120 = Color(0xFFCCCCCC),
    abiliaWhite110 = Color(0xFFE6E6E6),
    abiliaWhite100 = Color(0xFFFFFFFF);
const MaterialColor abiliaWhite = MaterialColor(
  _abiliaWhitePrimaryValue,
  <int, Color>{
    100: abiliaWhite100,
    110: abiliaWhite110,
    120: abiliaWhite120,
    135: abiliaWhite135,
    140: abiliaWhite140,
    150: abiliaWhite150,
  },
);

const int _abiliaBlackPrimaryValue = 0xFF000000;
const abiliaBlack100 = Color(_abiliaBlackPrimaryValue),
    abiliaBlack90 = Color(0xFF191919),
    abiliaBlack80 = Color(0xFF333333),
    abiliaBlack75 = Color(0xFF414141),
    abiliaBlack60 = Color(0xFF666666);
const MaterialColor black = MaterialColor(
  _abiliaBlackPrimaryValue,
  <int, Color>{
    60: abiliaBlack60,
    75: abiliaBlack75,
    80: abiliaBlack80,
    90: abiliaBlack90,
    100: abiliaBlack100,
  },
);

const int _abiliaGreenPrimaryValue = 0xFF339C37;
const abiliaGreen200 = Color(0xFF050F05),
    abiliaGreen180 = Color(0xFF0E2B0F),
    abiliaGreen160 = Color(0xFF184719),
    abiliaGreen140 = Color(0xFF216423),
    abiliaGreen120 = Color(0xFF2A802E),
    abiliaGreen100 = Color(_abiliaGreenPrimaryValue),
    abiliaGreen80 = Color(0xFF58AE5B),
    abiliaGreen60 = Color(0xFF7DC07F),
    abiliaGreen40 = Color(0xFFA2D2A4),
    abiliaGreen20 = Color(0xFFC7E4C8),
    abiliaGreen0 = Color(0xFFECF6EC);
const MaterialColor abiliaGreen = MaterialColor(
  _abiliaGreenPrimaryValue,
  <int, Color>{
    0: abiliaGreen0,
    20: abiliaGreen20,
    40: abiliaGreen40,
    60: abiliaGreen60,
    80: abiliaGreen80,
    100: abiliaGreen100,
    120: abiliaGreen120,
    140: abiliaGreen140,
    160: abiliaGreen160,
    180: abiliaGreen180,
    200: abiliaGreen200,
  },
);
