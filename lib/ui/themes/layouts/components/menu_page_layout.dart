import 'package:flutter/material.dart';

class MenuPageLayout {
  final EdgeInsets padding;
  final double crossAxisSpacing, mainAxisSpacing;
  final int maxCrossAxisCount;

  final MenuButtonLayout button;

  const MenuPageLayout({
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    this.crossAxisSpacing = 7.5,
    this.mainAxisSpacing = 7,
    this.maxCrossAxisCount = 3,
    this.button = const MenuButtonLayout(),
  });
}

class MenuPageLayoutMedium extends MenuPageLayout {
  const MenuPageLayoutMedium({
    EdgeInsets? padding,
    MenuButtonLayout? button,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) : super(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            crossAxisSpacing: crossAxisSpacing ?? 24,
            mainAxisSpacing: mainAxisSpacing ?? 24,
            maxCrossAxisCount: 3,
            button: button ?? const MenuButtonLayoutMedium());
}

class MenuPageLayoutLarge extends MenuPageLayoutMedium {
  const MenuPageLayoutLarge()
      : super(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          crossAxisSpacing: 40,
          mainAxisSpacing: 40,
          button: const MenuButtonLayoutLarge(),
        );
}

class MenuButtonLayout {
  final double iconSize, borderRadius, orangeDotInset, orangeDotRadius;
  final double width, height;
  final EdgeInsets padding;

  const MenuButtonLayout({
    this.iconSize = 48,
    this.borderRadius = 12,
    this.orangeDotInset = 4,
    this.orangeDotRadius = 6,
    this.width = 112,
    this.height = 112,
    this.padding = const EdgeInsets.fromLTRB(4, 8, 4, 20),
  });
}

class MenuButtonLayoutMedium extends MenuButtonLayout {
  const MenuButtonLayoutMedium({
    double? iconSize,
    double? borderRadius,
    double? orangeDotInset,
    double? orangeDotRadius,
    double? width,
    double? height,
    EdgeInsets? padding,
  }) : super(
          iconSize: iconSize ?? 96,
          borderRadius: borderRadius ?? 20,
          orangeDotInset: orangeDotInset ?? 6,
          orangeDotRadius: orangeDotRadius ?? 9,
          width: width ?? 220,
          height: height ?? 220,
          padding: padding ?? const EdgeInsets.fromLTRB(4, 16, 4, 46),
        );
}

class MenuButtonLayoutLarge extends MenuButtonLayoutMedium {
  const MenuButtonLayoutLarge()
      : super(
          iconSize: 128,
          orangeDotInset: 8,
          orangeDotRadius: 12,
          width: 306,
          height: 306,
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 58),
        );
}
