class FormPaddingLayout {
  final double smallVerticalItemDistance,
      verticalItemDistance,
      largeVerticalItemDistance,
      groupBottomDistance,
      groupTopDistance,
      horizontalItemDistance,
      largeHorizontalItemDistance,
      groupHorizontalDistance,
      largeGroupDistance,
      selectorDistance;

  const FormPaddingLayout({
    this.smallVerticalItemDistance = 8,
    this.verticalItemDistance = 8,
    this.largeVerticalItemDistance = 8,
    this.groupBottomDistance = 16,
    this.groupTopDistance = 24,
    this.horizontalItemDistance = 8,
    this.largeHorizontalItemDistance = 12,
    this.groupHorizontalDistance = 16,
    this.largeGroupDistance = 32,
    this.selectorDistance = 2,
  });
}

class FormPaddingLayoutMedium extends FormPaddingLayout {
  const FormPaddingLayoutMedium()
      : super(
          smallVerticalItemDistance: 8,
          verticalItemDistance: 12,
          largeVerticalItemDistance: 12,
          groupBottomDistance: 24,
          groupTopDistance: 36,
          horizontalItemDistance: 12,
          largeHorizontalItemDistance: 18,
          groupHorizontalDistance: 24,
          largeGroupDistance: 48,
          selectorDistance: 3,
        );
}
