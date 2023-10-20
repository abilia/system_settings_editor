import 'package:flutter/material.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/src/tokens/numericals.dart';

final textFieldBoxDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(
    Radius.circular(numerical200),
  ),
  color: MaterialStateColor.resolveWith(
    (states) {
      if (states.contains(MaterialState.disabled)) {
        return SurfaceColors.subdued;
      }
      return SurfaceColors.primary;
    },
  ),
);
