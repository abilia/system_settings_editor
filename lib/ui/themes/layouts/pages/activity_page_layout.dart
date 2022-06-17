import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPageLayout {
  final double titleFontSize,
      titleLineHeight,
      titleImageHorizontalSpacing,
      topInfoHeight,
      checkButtonHeight,
      dividerHeight,
      dividerIndentation,
      dividerTopPadding,
      dashWidth,
      dashSpacing,
      minTimeBoxWidth,
      timeBoxCurrentBorderWidth,
      timeBoxFutureBorderWidth;

  final Size timeBoxSize, timeCrossOverSize;

  final EdgeInsets timeRowPadding,
      timeBoxPadding,
      topInfoPadding,
      imagePadding,
      checkPadding,
      verticalInfoPaddingCheckable,
      verticalInfoPaddingNonCheckable,
      horizontalInfoPadding,
      checkButtonPadding,
      checkButtonContentPadding,
      checklistPadding,
      videoPlayerPadding;

  TextStyle titleStyle() => GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w400,
          height: titleLineHeight / titleFontSize,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );

  const ActivityPageLayout({
    this.topInfoHeight = 126,
    this.timeRowPadding = const EdgeInsets.only(bottom: 8),
    this.topInfoPadding = const EdgeInsets.only(left: 12, top: 15),
    this.titleImageHorizontalSpacing = 8,
    this.imagePadding = const EdgeInsets.fromLTRB(12, 0, 12, 12),
    this.checkPadding =
        const EdgeInsets.symmetric(horizontal: 55, vertical: 55),
    this.verticalInfoPaddingCheckable =
        const EdgeInsets.only(top: 16, bottom: 10),
    this.verticalInfoPaddingNonCheckable =
        const EdgeInsets.only(top: 16, bottom: 12),
    this.horizontalInfoPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.checkButtonPadding = const EdgeInsets.only(bottom: 16),
    this.checkButtonContentPadding = const EdgeInsets.fromLTRB(10, 10, 20, 10),
    this.checklistPadding = const EdgeInsets.fromLTRB(18, 12, 12, 0),
    this.videoPlayerPadding = const EdgeInsets.all(12),
    this.titleFontSize = 24, // headline4.2
    this.titleLineHeight = 28.13,
    this.checkButtonHeight = 48,
    this.dividerHeight = 1,
    this.dividerIndentation = 12,
    this.dividerTopPadding = 15,
    this.dashWidth = 7,
    this.dashSpacing = 8,
    this.timeCrossOverSize = const Size(64, 38),
    this.timeBoxPadding = const EdgeInsets.all(8),
    this.timeBoxSize = const Size(92, 52),
    this.minTimeBoxWidth = 72,
    this.timeBoxCurrentBorderWidth = 2,
    this.timeBoxFutureBorderWidth = 1,
  });
}

class ActivityPageLayoutMedium extends ActivityPageLayout {
  const ActivityPageLayoutMedium({
    double? topInfoHeight,
    double? titleFontSize,
    double? titleLineHeight,
    double? horizontalInfoPadding,
    Size? timeCrossOverSize,
    Size? timeBoxSize,
  }) : super(
          topInfoHeight: topInfoHeight ?? 232,
          timeRowPadding: const EdgeInsets.only(bottom: 16),
          topInfoPadding: const EdgeInsets.only(left: 16, top: 16),
          titleImageHorizontalSpacing: 16,
          imagePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          verticalInfoPaddingCheckable:
              const EdgeInsets.only(top: 24, bottom: 16),
          verticalInfoPaddingNonCheckable:
              const EdgeInsets.only(top: 24, bottom: 14),
          horizontalInfoPadding: const EdgeInsets.symmetric(horizontal: 16),
          checkButtonPadding: const EdgeInsets.only(bottom: 24),
          checklistPadding: const EdgeInsets.fromLTRB(27, 15, 28, 0),
          videoPlayerPadding: const EdgeInsets.all(16),
          titleFontSize: titleFontSize ?? 48, // headline4.2
          titleLineHeight: titleLineHeight ?? 56.25,
          checkButtonHeight: 72,
          checkButtonContentPadding:
              const EdgeInsets.fromLTRB(14.25, 15, 31.75, 15),
          dividerHeight: 2,
          dividerIndentation: 16,
          dividerTopPadding: 16,
          dashWidth: 12,
          dashSpacing: 12,
          timeCrossOverSize: timeCrossOverSize ?? const Size(112, 56),
          minTimeBoxWidth: 108,
          timeBoxSize: timeBoxSize ?? const Size(144, 80),
          timeBoxPadding: const EdgeInsets.all(16),
          timeBoxCurrentBorderWidth: 3,
          timeBoxFutureBorderWidth: 2,
        );
}

class ActivityPageLayoutLarge extends ActivityPageLayoutMedium {
  const ActivityPageLayoutLarge()
      : super(
          topInfoHeight: 272,
          titleFontSize: 64, // headline4.2
          titleLineHeight: 75,
          timeBoxSize: const Size(152, 80),
          timeCrossOverSize: const Size(118, 56),
        );
}
