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

class SelectorLayoutLarge extends SelectorLayoutMedium {
  const SelectorLayoutLarge() : super();
}
