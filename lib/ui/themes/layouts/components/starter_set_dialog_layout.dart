class StartedSetDialogLayout {
  final double imageHeadingDistance, headingBodyDistance;

  const StartedSetDialogLayout({
    this.imageHeadingDistance = 24,
    this.headingBodyDistance = 9,
  });
}

class StartedSetDialogLayoutMedium extends StartedSetDialogLayout {
  const StartedSetDialogLayoutMedium()
      : super(
          imageHeadingDistance: 36,
          headingBodyDistance: 16,
        );
}
