import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoplanner/ui/themes/colors.dart';

class LibraryPageLayout {
  final double mainAxisSpacing,
      crossAxisSpacing,
      folderIconSize,
      headerFontSize,
      childAspectRatio,
      emptyMessageTopPadding,
      folderImageRadius,
      backButtonIconSize;
  final int crossAxisCount;
  final EdgeInsets headerPadding,
      searchPadding,
      folderImagePadding,
      notePadding,
      contentPadding;
  final Size backButtonSize, searchButtonSize;

  const LibraryPageLayout({
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.crossAxisCount = 3,
    this.headerPadding = const EdgeInsets.fromLTRB(16, 4, 16, 4),
    this.searchPadding = const EdgeInsets.fromLTRB(12, 24, 12, 16),
    this.searchButtonSize = const Size(114, 48),
    this.backButtonSize = const Size(48, 48),
    this.backButtonIconSize = 32,
    this.folderImagePadding = const EdgeInsets.fromLTRB(10, 28, 10, 16),
    this.notePadding = const EdgeInsets.fromLTRB(5, 9, 5, 6),
    this.contentPadding = const EdgeInsets.only(top: 4),
    this.folderIconSize = 86,
    this.headerFontSize = 20,
    this.childAspectRatio = 1,
    this.emptyMessageTopPadding = 60,
    this.folderImageRadius = 4,
  });

  TextStyle get headerStyle => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: headerFontSize,
          color: AbiliaColors.black,
          fontWeight: FontWeight.w500,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
}

class LibraryPageLayoutMedium extends LibraryPageLayout {
  const LibraryPageLayoutMedium({
    int? crossAxisCount,
  }) : super(
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          crossAxisCount: crossAxisCount ?? 4,
          headerPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          searchPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          searchButtonSize: const Size(166, 80),
          backButtonSize: const Size(80, 80),
          backButtonIconSize: 56,
          folderImagePadding: const EdgeInsets.fromLTRB(15, 42, 15, 24),
          notePadding: const EdgeInsets.fromLTRB(7.5, 13.5, 7.5, 9),
          contentPadding: const EdgeInsets.only(top: 6),
          folderIconSize: 128,
          headerFontSize: 32,
          childAspectRatio: 183 / 188,
          emptyMessageTopPadding: 90,
          folderImageRadius: 6,
        );
}

class LibraryPageLayoutLarge extends LibraryPageLayoutMedium {
  const LibraryPageLayoutLarge()
      : super(
          crossAxisCount: 6,
        );
}
