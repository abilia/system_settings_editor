class StartupPageLayout {
  const StartupPageLayout({
    this.logoDistance = 32,
    this.textPickDistance = 56,
  });

  final double logoDistance, textPickDistance;
}

class StartupPageLayoutMedium extends StartupPageLayout {
  const StartupPageLayoutMedium()
      : super(
          logoDistance: 32,
          textPickDistance: 56,
        );
}
