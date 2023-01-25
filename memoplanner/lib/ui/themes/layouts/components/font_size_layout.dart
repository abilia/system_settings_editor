class FontSize {
  final double displayLarge,
      displayMedium,
      displaySmall,
      headlineMedium,
      headlineSmall,
      titleLarge,
      titleMedium,
      titleSmall,
      bodyLarge,
      bodyMedium,
      bodySmall,
      labelLarge,
      labelSmall;

  const FontSize({
    this.displayLarge = 96,
    this.displayMedium = 60,
    this.displaySmall = 48,
    this.headlineMedium = 34,
    this.headlineSmall = 24,
    this.titleLarge = 20,
    this.titleMedium = 16,
    this.titleSmall = 14,
    this.bodyLarge = 16,
    this.bodyMedium = 14,
    this.bodySmall = 12,
    this.labelLarge = 16,
    this.labelSmall = 10,
  });
}

class FontSizeMedium extends FontSize {
  const FontSizeMedium({
    double? headline3,
    double? subtitle1,
  }) : super(
          displayLarge: 144,
          displayMedium: 90,
          displaySmall: headline3 ?? 72,
          headlineMedium: 45,
          headlineSmall: 38,
          titleLarge: 32,
          titleMedium: subtitle1 ?? 24,
          titleSmall: 21,
          bodyLarge: 24,
          bodyMedium: 21,
          bodySmall: 20,
          labelLarge: 24,
          labelSmall: 15,
        );
}

class FontSizeLarge extends FontSizeMedium {
  const FontSizeLarge() : super(headline3: 64, subtitle1: 32);
}
