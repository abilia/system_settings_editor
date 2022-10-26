class ToolbarLayout {
  final double height, horizontalPadding, bottomPadding;

  const ToolbarLayout({
    this.height = 64,
    this.horizontalPadding = 16,
    this.bottomPadding = 0,
  });
}

class ToolbarLayoutMedium extends ToolbarLayout {
  const ToolbarLayoutMedium() : super(height: 120);
}
