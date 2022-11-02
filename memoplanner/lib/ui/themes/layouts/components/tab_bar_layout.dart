import 'package:flutter/material.dart';

class TabBarLayout {
  final TabItemLayout item;
  final double height, bottomPadding;

  const TabBarLayout({
    this.item = const TabItemLayout(),
    this.height = 64,
    this.bottomPadding = 0,
  });
}

class TabBarLayoutMedium extends TabBarLayout {
  const TabBarLayoutMedium()
      : super(
          item: const TabItemLayoutMedium(),
          height: 104,
          bottomPadding: 8,
        );
}

class TabItemLayout {
  final double width, border;
  final EdgeInsets padding;

  const TabItemLayout({
    this.width = 64,
    this.border = 1,
    this.padding = const EdgeInsets.only(left: 4, top: 4, right: 4),
  });
}

class TabItemLayoutMedium extends TabItemLayout {
  const TabItemLayoutMedium()
      : super(
          width: 118,
          border: 2,
          padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
        );
}
