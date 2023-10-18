import 'dart:ui';

import 'package:flutter/material.dart';

class CaryTheme extends ThemeExtension<CaryTheme> {
  final double clockSize;
  final Size clockDatePadding;

  const CaryTheme({
    required this.clockSize,
    required this.clockDatePadding,
  });

  factory CaryTheme.of(BuildContext context) =>
      Theme.of(context).extension<CaryTheme>() ?? CaryTheme.expanded;

  @override
  CaryTheme copyWith({
    double? clockSize,
    double? datePadding,
    Size? clockDatePadding,
  }) {
    return CaryTheme(
      clockSize: clockSize ?? this.clockSize,
      clockDatePadding: clockDatePadding ?? this.clockDatePadding,
    );
  }

  static const CaryTheme collapsed = CaryTheme(
    clockSize: 288,
    clockDatePadding: Size(0, 24),
  );

  static const CaryTheme expanded = CaryTheme(
    clockSize: 136,
    clockDatePadding: Size(8, 0),
  );

  @override
  CaryTheme lerp(CaryTheme? other, double t) {
    if (other is! CaryTheme) return this;
    return CaryTheme(
      clockSize: lerpDouble(clockSize, other.clockSize, t) ?? clockSize,
      clockDatePadding: Size.lerp(
            clockDatePadding,
            other.clockDatePadding,
            t,
          ) ??
          clockDatePadding,
    );
  }
}
