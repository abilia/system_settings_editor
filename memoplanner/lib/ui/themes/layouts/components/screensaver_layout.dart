import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoplanner/ui/themes/colors.dart';

class ScreensaverLayout {
  final double clockHeight,
      clockSeparation,
      digitalClockTextSize,
      digitalClockLineHeight;
  final EdgeInsets clockPadding, titleBarPadding;

  const ScreensaverLayout({
    this.clockHeight = 288,
    this.clockSeparation = 48,
    this.digitalClockTextSize = 80,
    this.digitalClockLineHeight = 93.75,
    this.titleBarPadding = const EdgeInsets.only(top: 24),
    this.clockPadding = const EdgeInsets.only(top: 138),
  });

  TextStyle get digitalClockTextStyle => GoogleFonts.roboto(
          textStyle: TextStyle(
        fontSize: digitalClockTextSize,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        color: AbiliaColors.white,
        height: digitalClockLineHeight / digitalClockTextSize,
        leadingDistribution: TextLeadingDistribution.even,
      ));
}
