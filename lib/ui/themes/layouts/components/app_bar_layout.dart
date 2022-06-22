import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/all.dart';

class AppBarLayout {
  final double horizontalPadding,
      clockPadding,
      largeHeight,
      height,
      previewWidth;

  final BorderRadius borderRadius;
  final TextStyle _textStyle;

  const AppBarLayout({
    this.horizontalPadding = 16,
    this.clockPadding = 8,
    this.largeHeight = 80,
    this.height = 68,
    this.previewWidth = 375,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    ),
    TextStyle? textStyle,
  }) : _textStyle = textStyle ??
            const TextStyle(
              fontSize: 20,
              height: 23.44 / 20,
              fontWeight: FontWeight.w500,
              leadingDistribution: TextLeadingDistribution.even,
            );

  TextStyle get textStyle => GoogleFonts.roboto(textStyle: _textStyle);
}

class AppBarLayoutMedium extends AppBarLayout {
  const AppBarLayoutMedium({
    double? largeHeight,
    double? horizontalPadding,
    double? clockPadding,
    TextStyle? textStyle,
  }) : super(
          horizontalPadding: horizontalPadding ?? 16,
          clockPadding: clockPadding ?? 16,
          largeHeight: largeHeight ?? 148,
          height: 104,
          previewWidth: 562.5,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          textStyle: textStyle ??
              const TextStyle(
                fontSize: 32,
                height: 40 / 32,
                fontWeight: FontWeight.w500,
                leadingDistribution: TextLeadingDistribution.even,
              ),
        );
}

class AppBarLayoutLarge extends AppBarLayoutMedium {
  const AppBarLayoutLarge()
      : super(
          largeHeight: 200,
          horizontalPadding: 32,
          textStyle: const TextStyle(
            fontSize: 48,
            height: 56.25 / 48,
            fontWeight: FontWeight.w400,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        );
}