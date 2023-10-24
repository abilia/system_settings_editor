import 'package:flutter/material.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/src/tokens/numericals.dart';

const roundedRectangleBorder200 = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(numerical200),
  ),
);

const roundedRectangleBorder300 = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(numerical300),
  ),
);

const roundedRectangleBorder500 = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(numerical500),
  ),
);

const roundedRectangleBorder600 = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(numerical600),
  ),
);

final borderSideGrey300 = BorderSide(
  color: SurfaceColors.active,
  width: numerical2px,
);

final inputBorder = OutlineInputBorder(
  borderRadius: const BorderRadius.all(
    Radius.circular(numerical200),
  ),
  borderSide: borderSideGrey300.copyWith(width: numerical1px),
);

final activeBorder = inputBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(
    width: numerical1px,
    color: SurfaceColors.borderActive,
  ),
);

final errorBorder = inputBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(
    width: numerical1px,
    color: SurfaceColors.borderFocus,
  ),
);

final successBorder = inputBorder.copyWith(
  borderSide: borderSideGrey300.copyWith(
    width: numerical1px,
    color: SurfaceColors.positiveSelected,
  ),
);
