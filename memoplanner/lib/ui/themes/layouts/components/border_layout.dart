class BorderLayout {
  final double thin, medium, activityInfoSideDotsWidth;

  const BorderLayout({
    this.thin = 1,
    this.medium = 2,
    this.activityInfoSideDotsWidth = 1,
  });
}

class BorderLayoutMedium extends BorderLayout {
  const BorderLayoutMedium({activityInfoSideDotsWidth})
      : super(
            thin: 1.5,
            medium: 3,
            activityInfoSideDotsWidth: activityInfoSideDotsWidth ?? 1.5);
}

class BorderLayoutLarge extends BorderLayout {
  const BorderLayoutLarge() : super(activityInfoSideDotsWidth: 3);
}
