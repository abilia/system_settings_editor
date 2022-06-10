class FontSize {
  final FontHeight height;
  final double headline1,
      headline2,
      headline3,
      headline4,
      headline5,
      headline6,
      subtitle1,
      subtitle2,
      bodyText1,
      bodyText2,
      bodyText3,
      caption,
      button,
      overline;

  const FontSize({
    this.headline1 = 96,
    this.headline2 = 60,
    this.headline3 = 48,
    this.headline4 = 34,
    this.headline5 = 24,
    this.headline6 = 20,
    this.subtitle1 = 16,
    this.subtitle2 = 14,
    this.bodyText1 = 16,
    this.bodyText2 = 14,
    this.bodyText3 = 16,
    this.caption = 12,
    this.button = 16,
    this.overline = 10,
    this.height = const FontHeight(),
  });
}

class FontSizeMedium extends FontSize {
  const FontSizeMedium({
    double? bodyText3,
    FontHeight? height,
  }) : super(
          headline1: 144,
          headline2: 90,
          headline3: 72,
          headline4: 45,
          headline5: 38,
          headline6: 32,
          subtitle1: 24,
          subtitle2: 21,
          bodyText1: 24,
          bodyText2: 21,
          bodyText3: bodyText3 ?? 24,
          caption: 20,
          button: 24,
          overline: 15,
          height: height ?? const FontHeightMedium(),
        );
}

class FontSizeLarge extends FontSizeMedium {
  const FontSizeLarge()
      : super(
          bodyText3: 36,
          height: const FontHeightLarge(),
        );
}

class FontHeight {
  final double bodyText3;

  const FontHeight({
    this.bodyText3 = 18 / 16.0,
  });
}

class FontHeightMedium extends FontHeight {
  const FontHeightMedium({
    double? bodyText3,
  }) : super(
          bodyText3: bodyText3 ?? 42 / 24.0,
        );
}

class FontHeightLarge extends FontHeightMedium {
  const FontHeightLarge()
      : super(
          bodyText3: 1,
        );
}
