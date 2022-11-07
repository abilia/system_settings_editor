class AboutLayout {
  final double smallTextSpacing;
  final double horizontalTextSpacing, verticalTextSpacing;

  const AboutLayout({
    this.smallTextSpacing = 0,
    this.horizontalTextSpacing = 12,
    this.verticalTextSpacing = 0,
  });
}

class AboutLayoutMedium extends AboutLayout {
  const AboutLayoutMedium()
      : super(
          smallTextSpacing: 8,
          verticalTextSpacing: 4,
        );
}
