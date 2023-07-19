import 'package:google_fonts/google_fonts.dart';
import 'package:memoplanner/ui/all.dart';

class AppBarLayout {
  final double horizontalPadding,
      clockPadding,
      largeHeight,
      mediumHeight,
      smallHeight,
      monthStepperHeight,
      thirdLineFontSizeMin;

  final EdgeInsets titlesPadding, titleSpacing, iconPadding, searchPadding;
  final BorderRadius borderRadius;
  final TextStyle _textStyle;

  const AppBarLayout({
    this.iconPadding = const EdgeInsets.only(right: 8),
    this.horizontalPadding = 16,
    this.clockPadding = 8,
    this.largeHeight = 80,
    this.mediumHeight = 80,
    this.smallHeight = 68,
    this.monthStepperHeight = 68,
    this.thirdLineFontSizeMin = 14,
    this.titlesPadding = const EdgeInsets.symmetric(horizontal: 2),
    this.titleSpacing = const EdgeInsets.symmetric(vertical: 2),
    this.searchPadding = const EdgeInsets.only(left: 24, right: 8),
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
    double? mediumHeight,
    double? smallHeight,
    double? horizontalPadding,
    double? clockPadding,
    double? monthStepperHeight,
    TextStyle? textStyle,
  }) : super(
          iconPadding: const EdgeInsets.only(right: 12),
          horizontalPadding: horizontalPadding ?? 16,
          clockPadding: clockPadding ?? 16,
          largeHeight: largeHeight ?? 148,
          mediumHeight: mediumHeight ?? 148,
          smallHeight: 104,
          monthStepperHeight: monthStepperHeight ?? 116,
          titlesPadding: const EdgeInsets.symmetric(horizontal: 12),
          titleSpacing: const EdgeInsets.symmetric(vertical: 12),
          searchPadding: const EdgeInsets.only(left: 32, right: 12),
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
          monthStepperHeight: 200,
          horizontalPadding: 32,
          textStyle: const TextStyle(
            fontSize: 48,
            height: 56.25 / 48,
            fontWeight: FontWeight.w400,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        );
}
