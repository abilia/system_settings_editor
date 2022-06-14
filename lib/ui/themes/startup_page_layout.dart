class StartupPageLayout {
  const StartupPageLayout({
    this.welcomeLogoDistance = 48,
    this.startButtonDistance = 64,
    this.welcomeButtonWidth = 412,
    this.contentWidth = 540,
    this.buttonHeight = 96,
    this.logoDistance = 32,
    this.pageTwoButtonWidth = 264,
    this.textPickDistance = 56,
    this.welcomeLogoHeight = 164,
  });

  final double welcomeLogoDistance,
      startButtonDistance,
      welcomeButtonWidth,
      buttonHeight,
      contentWidth,
      logoDistance,
      pageTwoButtonWidth,
      textPickDistance,
      welcomeLogoHeight;
}

class StartupPageLayoutMedium extends StartupPageLayout {
  const StartupPageLayoutMedium()
      : super(
          welcomeLogoDistance: 48,
          startButtonDistance: 64,
          welcomeButtonWidth: 412,
          contentWidth: 540,
          buttonHeight: 96,
          logoDistance: 32,
          pageTwoButtonWidth: 264,
          textPickDistance: 56,
          welcomeLogoHeight: 164,
        );
}
