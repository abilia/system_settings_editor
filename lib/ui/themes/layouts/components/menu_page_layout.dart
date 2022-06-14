import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/themes/colors.dart';

class MenuPageLayout {
  final EdgeInsets padding;
  final double crossAxisSpacing, mainAxisSpacing;
  final TextStyle _textStyle;

  final MenuButtonLayout button;

  const MenuPageLayout({
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    this.crossAxisSpacing = 7.5,
    this.mainAxisSpacing = 7,
    this.button = const MenuButtonLayout(),
    TextStyle? textStyle,
  }) : _textStyle = textStyle ??
            const TextStyle(
              color: AbiliaColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 18 / 16.0,
              leadingDistribution: TextLeadingDistribution.even,
            );

  TextStyle get textStyle => GoogleFonts.roboto(textStyle: _textStyle);
}

class MenuPageLayoutMedium extends MenuPageLayout {
  const MenuPageLayoutMedium({
    EdgeInsets? padding,
    MenuButtonLayout? button,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    TextStyle? textStyle,
  }) : super(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          crossAxisSpacing: crossAxisSpacing ?? 24,
          mainAxisSpacing: mainAxisSpacing ?? 24,
          button: button ?? const MenuButtonLayoutMedium(),
          textStyle: textStyle ??
              const TextStyle(
                color: AbiliaColors.black,
                fontSize: 24,
                fontWeight: FontWeight.w400,
                height: 42 / 24.0,
                leadingDistribution: TextLeadingDistribution.even,
              ),
        );
}

class MenuPageLayoutLarge extends MenuPageLayoutMedium {
  const MenuPageLayoutLarge()
      : super(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          crossAxisSpacing: 40,
          mainAxisSpacing: 40,
          button: const MenuButtonLayoutLarge(),
          textStyle: const TextStyle(
            color: AbiliaColors.black,
            fontSize: 36,
            fontWeight: FontWeight.w400,
            height: 1,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        );
}

class MenuButtonLayout {
  final double size, iconSize, borderRadius, orangeDotInset, orangeDotRadius;
  final EdgeInsets padding;

  const MenuButtonLayout({
    this.size = 112,
    this.iconSize = 48,
    this.borderRadius = 12,
    this.orangeDotInset = 4,
    this.orangeDotRadius = 6,
    this.padding = const EdgeInsets.fromLTRB(4, 8, 4, 20),
  });
}

class MenuButtonLayoutMedium extends MenuButtonLayout {
  const MenuButtonLayoutMedium({
    double? size,
    double? iconSize,
    double? borderRadius,
    double? orangeDotInset,
    double? orangeDotRadius,
    EdgeInsets? padding,
  }) : super(
          size: size ?? 220,
          iconSize: iconSize ?? 96,
          borderRadius: borderRadius ?? 20,
          orangeDotInset: orangeDotInset ?? 6,
          orangeDotRadius: orangeDotRadius ?? 9,
          padding: padding ?? const EdgeInsets.fromLTRB(4, 16, 4, 46),
        );
}

class MenuButtonLayoutLarge extends MenuButtonLayoutMedium {
  const MenuButtonLayoutLarge()
      : super(
          size: 306,
          iconSize: 128,
          orangeDotInset: 8,
          orangeDotRadius: 12,
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 58),
        );
}
