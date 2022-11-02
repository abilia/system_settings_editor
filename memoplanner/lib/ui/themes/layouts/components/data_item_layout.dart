import 'package:flutter/material.dart';

class DataItemLayout {
  final double borderRadius;
  final DataItemPictureLayout picture;

  const DataItemLayout({
    this.borderRadius = 12,
    this.picture = const DataItemPictureLayout(),
  });
}

class DataItemPictureLayout {
  final double stickerIconSize;
  final Size stickerSize;
  final EdgeInsets imagePadding, titlePadding;

  const DataItemPictureLayout({
    this.stickerIconSize = 16,
    this.stickerSize = const Size(32, 32),
    this.imagePadding = const EdgeInsets.only(left: 12, right: 12, bottom: 3),
    this.titlePadding =
        const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 2),
  });
}

/// Called DataItem (list) in Figma
class ListDataItemLayout {
  final EdgeInsets folderPadding, imagePadding, textAndSubtitlePadding;
  final double iconSize;
  final double? secondaryTextHeight;

  const ListDataItemLayout({
    this.folderPadding = const EdgeInsets.symmetric(horizontal: 6),
    this.imagePadding = const EdgeInsets.only(left: 4, right: 8),
    this.textAndSubtitlePadding = const EdgeInsets.only(top: 3, bottom: 7),
    this.iconSize = 24,
    this.secondaryTextHeight,
  });
}
