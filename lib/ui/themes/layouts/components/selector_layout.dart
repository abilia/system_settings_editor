class SelectorLayout {
  final double height, iconSize;

  const SelectorLayout({
    this.height = 64,
    this.iconSize = 32,
  });
}

class SelectorLayoutMedium extends SelectorLayout {
  const SelectorLayoutMedium()
      : super(
          height: 96,
          iconSize: 48,
        );
}

class SelectorLayoutLarge extends SelectorLayoutMedium {
  const SelectorLayoutLarge() : super();
}
