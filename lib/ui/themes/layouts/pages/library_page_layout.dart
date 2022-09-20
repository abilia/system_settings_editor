import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/ui/themes/colors.dart';

class LibraryPageLayout {
  final double mainAxisSpacing,
      crossAxisSpacing,
      folderIconSize,
      headerFontSize,
      childAspectRatio,
      imageHeight,
      imageWidth,
      textImageDistance,
      emptyMessageTopPadding,
      folderImageRadius;
  final int crossAxisCount;
  final EdgeInsets headerPadding,
      folderImagePadding,
      notePadding,
      contentPadding;

  const LibraryPageLayout({
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.crossAxisCount = 3,
    this.headerPadding = const EdgeInsets.fromLTRB(16, 12, 0, 3),
    this.folderImagePadding = const EdgeInsets.fromLTRB(10, 28, 10, 16),
    this.notePadding = const EdgeInsets.fromLTRB(5, 9, 5, 6),
    this.contentPadding = const EdgeInsets.all(4),
    this.folderIconSize = 86,
    this.headerFontSize = 20,
    this.childAspectRatio = 1,
    this.imageHeight = 86,
    this.imageWidth = 86,
    this.textImageDistance = 2,
    this.emptyMessageTopPadding = 60,
    this.folderImageRadius = 4,
  });

  TextStyle headerStyle() => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: headerFontSize,
          color: AbiliaColors.black,
          fontWeight: FontWeight.w500,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
}

class LibraryPageLayoutMedium extends LibraryPageLayout {
  const LibraryPageLayoutMedium()
      : super(
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          crossAxisCount: 4,
          headerPadding: const EdgeInsets.fromLTRB(24, 12, 0, 3),
          folderImagePadding: const EdgeInsets.fromLTRB(15, 42, 15, 24),
          notePadding: const EdgeInsets.fromLTRB(7.5, 13.5, 7.5, 9),
          contentPadding: const EdgeInsets.all(6),
          folderIconSize: 128,
          headerFontSize: 32,
          childAspectRatio: 183 / 188,
          imageHeight: 144,
          imageWidth: 140,
          textImageDistance: 3,
          emptyMessageTopPadding: 90,
          folderImageRadius: 6,
        );
}
