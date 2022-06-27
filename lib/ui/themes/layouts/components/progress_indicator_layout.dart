class ProgressIndicatorLayout {
  final double strokeWidth;
  const ProgressIndicatorLayout({
    this.strokeWidth = 6,
  });
}

class ProgressIndicatorLayoutMedium extends ProgressIndicatorLayout {
  const ProgressIndicatorLayoutMedium() : super(strokeWidth: 9);
}
