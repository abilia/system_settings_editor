import 'package:memoplanner/ui/all.dart';

class MonthPreviewLayout {
  final double monthPreviewBorderWidth,
      activityListTopPadding,
      activityListBottomPadding,
      headingHeight,
      headingFullDayActivityHeight,
      headingFullDayActivityWidth,
      headingButtonIconSize;

  final EdgeInsets monthListPreviewPadding,
      monthListPreviewCollapsedPadding,
      headingPadding,
      noSelectedDayPadding,
      crossOverPadding;

  final Size dateTextCrossOverSize;

  const MonthPreviewLayout({
    this.monthPreviewBorderWidth = 1,
    this.activityListTopPadding = 12,
    this.activityListBottomPadding = 64,
    this.headingHeight = 48,
    this.headingFullDayActivityHeight = 40,
    this.headingFullDayActivityWidth = 40,
    this.headingButtonIconSize = 24,
    this.monthListPreviewPadding =
        const EdgeInsets.only(left: 8, top: 16, right: 8),
    this.monthListPreviewCollapsedPadding =
        const EdgeInsets.only(left: 8, top: 82, right: 8),
    this.headingPadding = const EdgeInsets.only(left: 12, right: 8),
    this.noSelectedDayPadding = const EdgeInsets.only(top: 32),
    this.crossOverPadding = const EdgeInsets.all(4),
    this.dateTextCrossOverSize = const Size(163, 32),
  });
}

class MonthPreviewLayoutMedium extends MonthPreviewLayout {
  const MonthPreviewLayoutMedium({
    double? headingHeight,
    double? fullDayActivityHeight,
  }) : super(
          monthPreviewBorderWidth: 2,
          activityListTopPadding: 32,
          activityListBottomPadding: 96,
          headingHeight: headingHeight ?? 72,
          headingFullDayActivityHeight: fullDayActivityHeight ?? 54,
          headingFullDayActivityWidth: 57,
          headingButtonIconSize: 36,
          monthListPreviewPadding:
              const EdgeInsets.only(left: 12, top: 32, right: 12),
          headingPadding: const EdgeInsets.only(left: 18, right: 16),
          noSelectedDayPadding: const EdgeInsets.only(top: 64),
          crossOverPadding: const EdgeInsets.all(6),
          dateTextCrossOverSize: const Size(336, 56),
        );
}

class MonthPreviewLayoutLarge extends MonthPreviewLayoutMedium {
  const MonthPreviewLayoutLarge()
      : super(
          headingHeight: 80,
          fullDayActivityHeight: 56,
        );
}
