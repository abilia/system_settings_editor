class BorderLayout {
  final double thin, medium, dotsThin;

  const BorderLayout({
    this.thin = 1,
    this.medium = 2,
    this.dotsThin = 1,
  });
}

class BorderLayoutMedium extends BorderLayout {
  const BorderLayoutMedium({dotsThin})
      : super(thin: 1.5, medium: 3, dotsThin: dotsThin ?? 1.5);
}

class BorderLayoutLarge extends BorderLayout {
  const BorderLayoutLarge() : super(dotsThin: 3);
}
