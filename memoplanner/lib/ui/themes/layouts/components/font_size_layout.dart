class FontSize {
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
    this.caption = 12,
    this.button = 16,
    this.overline = 10,
  });
}

class FontSizeMedium extends FontSize {
  const FontSizeMedium({
    double? headline3,
    double? subtitle1,
  }) : super(
          headline1: 144,
          headline2: 90,
          headline3: headline3 ?? 72,
          headline4: 45,
          headline5: 38,
          headline6: 32,
          subtitle1: subtitle1 ?? 24,
          subtitle2: 21,
          bodyText1: 24,
          bodyText2: 21,
          caption: 20,
          button: 24,
          overline: 15,
        );
}

class FontSizeLarge extends FontSizeMedium {
  const FontSizeLarge() : super(headline3: 64, subtitle1: 32);
}
