class ToolbarLayout {
  final double height, horizontalPadding;

  const ToolbarLayout({
    this.height = 64,
    this.horizontalPadding = 16,
  });
}

class ToolbarLayoutMedium extends ToolbarLayout {
  const ToolbarLayoutMedium() : super(height: 120);
}
