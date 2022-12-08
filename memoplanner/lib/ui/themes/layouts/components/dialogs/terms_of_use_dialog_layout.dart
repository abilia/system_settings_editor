class TermsOfUseDialogLayout {
  final double imageSize;
  final double imageHeadingDistance, headingTextDistance, bodyTextDistance;

  const TermsOfUseDialogLayout({
    this.imageSize = 96,
    this.imageHeadingDistance = 24,
    this.headingTextDistance = 9,
    this.bodyTextDistance = 24,
  });
}

class TermsOfUseDialogLayoutMedium extends TermsOfUseDialogLayout {
  const TermsOfUseDialogLayoutMedium()
      : super(
          imageSize: 254,
          imageHeadingDistance: 36,
          headingTextDistance: 16,
          bodyTextDistance: 72,
        );
}
