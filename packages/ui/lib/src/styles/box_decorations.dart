import 'package:flutter/material.dart';
import 'package:ui/src/tokens/colors.dart';
import 'package:ui/src/tokens/numericals.dart';

final textFieldBoxDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(
    Radius.circular(numerical300),
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

final textFieldBoxDecorationSelected = textFieldBoxDecoration.copyWith(
  boxShadow: [
    const BoxShadow(
      color: Color(0xFFD5D7F5),
      spreadRadius: numerical200,
    ),
  ],
);
