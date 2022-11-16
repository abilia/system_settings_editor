class TermsOfUseDialogLayout {
  final double imageHeadingDistance, headingTextDistance, bodyTextDistance;

  const TermsOfUseDialogLayout({
    this.imageHeadingDistance = 24,
    this.headingTextDistance = 9,
    this.bodyTextDistance = 24,
  });
}

class TermsOfUseDialogLayoutMedium extends TermsOfUseDialogLayout {
  const TermsOfUseDialogLayoutMedium()
      : super(
          imageHeadingDistance: 36,
          headingTextDistance: 16,
          bodyTextDistance: 72,
        );
}
