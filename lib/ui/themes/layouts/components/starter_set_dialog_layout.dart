class StarterSetDialogLayout {
  final double imageHeadingDistance, headingBodyDistance;

  const StarterSetDialogLayout({
    this.imageHeadingDistance = 24,
    this.headingBodyDistance = 9,
  });
}

class StarterSetDialogLayoutMedium extends StarterSetDialogLayout {
  const StarterSetDialogLayoutMedium()
      : super(
          imageHeadingDistance: 36,
          headingBodyDistance: 16,
        );
}
