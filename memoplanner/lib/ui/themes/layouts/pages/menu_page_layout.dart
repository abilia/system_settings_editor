import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoplanner/ui/themes/colors.dart';

class MenuPageLayout {
  final TextStyle _textStyle;
  final EdgeInsets aboutButtonPadding;

  final MenuButtonsLayout buttons;

  const MenuPageLayout({
    this.aboutButtonPadding = const EdgeInsets.only(right: 24),
    this.buttons = const MenuButtonsLayout(),
    TextStyle? textStyle,
  }) : _textStyle = textStyle ?? const TextStyle();

  TextStyle get textStyle => GoogleFonts.roboto(textStyle: _textStyle);
}

class MenuPageLayoutMedium extends MenuPageLayout {
  const MenuPageLayoutMedium({
    MenuButtonsLayout? buttons,
    double? mainAxisSpacing,
    TextStyle? textStyle,
  }) : super(
          buttons: buttons ?? const MenuButtonLayoutMedium(),
          textStyle: textStyle ??
              const TextStyle(
                color: AbiliaColors.black,
                fontSize: 24,
                fontWeight: FontWeight.w400,
                height: 30 / 24.0,
                leadingDistribution: TextLeadingDistribution.even,
              ),
        );
}

class MenuPageLayoutLarge extends MenuPageLayoutMedium {
  const MenuPageLayoutLarge()
      : super(
          buttons: const MenuButtonLayoutLarge(),
          textStyle: const TextStyle(
            color: AbiliaColors.black,
            fontSize: 36,
            fontWeight: FontWeight.w400,
            height: 42 / 36.0,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        );
}

class MenuButtonsLayout {
  final double size, spacing, iconSize, borderRadius;
  final EdgeInsets padding;

  const MenuButtonsLayout({
    this.size = 112,
    this.spacing = 7,
    this.iconSize = 48,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.fromLTRB(4, 8, 4, 20),
  });
}

class MenuButtonLayoutMedium extends MenuButtonsLayout {
  const MenuButtonLayoutMedium({
    double? size,
    double? spacing,
    double? iconSize,
    double? borderRadius,
    EdgeInsets? padding,
  }) : super(
          size: size ?? 235,
          spacing: spacing ?? 24,
          iconSize: iconSize ?? 96,
          borderRadius: borderRadius ?? 20,
          padding: padding ?? const EdgeInsets.fromLTRB(4, 16, 4, 46),
        );
}

class MenuButtonLayoutLarge extends MenuButtonLayoutMedium {
  const MenuButtonLayoutLarge()
      : super(
          size: 306,
          spacing: 40,
          iconSize: 128,
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 58),
        );
}
