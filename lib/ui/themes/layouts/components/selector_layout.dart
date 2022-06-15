class SelectorLayout {
  final double iconSize;

  const SelectorLayout({
    this.iconSize = 32,
  });
}

class SelectorLayoutMedium extends SelectorLayout {
  const SelectorLayoutMedium()
      : super(
          iconSize: 48,
        );
}
