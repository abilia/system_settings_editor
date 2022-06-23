import 'package:flutter/material.dart';

class TimerPageLayout {
  final double topInfoHeight, imageSize, imagePadding, pauseTextHeight;

  final EdgeInsets topPadding, pauseTextPadding, mainContentPadding;

  const TimerPageLayout({
    this.topInfoHeight = 126,
    this.imageSize = 96,
    this.imagePadding = 8,
    this.pauseTextHeight = 40,
    this.mainContentPadding = const EdgeInsets.fromLTRB(30, 20, 30, 0),
    this.topPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    this.pauseTextPadding = const EdgeInsets.only(top: 16),
  });
}

class TimerPageLayoutMedium extends TimerPageLayout {
  const TimerPageLayoutMedium(
      {double? topInfoHeight, double? imageSize, EdgeInsets? topPadding})
      : super(
          topInfoHeight: topInfoHeight ?? 232,
          imageSize: imageSize ?? 200,
          imagePadding: 16,
          topPadding: topPadding ?? const EdgeInsets.all(16),
        );
}

class TimerPageLayoutLarge extends TimerPageLayoutMedium {
  const TimerPageLayoutLarge()
      : super(
            topInfoHeight: 272,
            imageSize: 240,
            topPadding: const EdgeInsets.all(18));
}
