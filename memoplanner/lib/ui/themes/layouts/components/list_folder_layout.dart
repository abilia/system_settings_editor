import 'package:flutter/material.dart';

class ListFolderLayout {
  final double iconSize, imageBorderRadius;
  final EdgeInsets margin, imagePadding;

  const ListFolderLayout({
    this.iconSize = 42,
    this.imageBorderRadius = 2,
    this.imagePadding = const EdgeInsets.fromLTRB(6, 16, 6, 11),
    this.margin = const EdgeInsets.only(left: 2, right: 6),
  });
}
