import 'package:memoplanner/ui/all.dart';

class MonthCalendarLayout {
  final int monthContentFlex, monthListPreviewFlex;

  final double monthHeadingHeight,
      dayRadius,
      dayRadiusHighlighted,
      dayBorderWidth,
      dayBorderWidthHighlighted,
      dayHeaderHeight,
      dayHeadingFontSize,
      fullDayActivityFontSize,
      weekNumberWidth,
      hasActivitiesDotRadius;

  final EdgeInsets dayViewPadding,
      dayViewPaddingHighlighted,
      dayViewMargin,
      dayViewMarginHighlighted,
      dayHeaderPadding,
      dayContainerPadding,
      crossOverPadding,
      hasActivitiesDotPadding,
      activityTextContentPadding;

  final MonthPreviewLayout monthPreview;

  const MonthCalendarLayout({
    this.monthContentFlex = 242,
    this.monthListPreviewFlex = 229,
    this.monthHeadingHeight = 32,
    this.dayRadius = 8,
    this.dayRadiusHighlighted = 10,
    this.dayBorderWidth = 1,
    this.dayBorderWidthHighlighted = 4,
    this.dayHeaderHeight = 24,
    this.dayHeadingFontSize = 14,
    this.fullDayActivityFontSize = 12,
    this.weekNumberWidth = 24,
    this.hasActivitiesDotRadius = 3,
    this.dayViewPadding = const EdgeInsets.all(4),
    this.dayViewPaddingHighlighted = const EdgeInsets.all(6),
    this.dayViewMargin = const EdgeInsets.all(2),
    this.dayViewMarginHighlighted = const EdgeInsets.all(0),
    this.dayHeaderPadding = const EdgeInsets.only(left: 4, top: 7, right: 4),
    this.dayContainerPadding =
        const EdgeInsets.only(left: 5, top: 3, right: 5, bottom: 5),
    this.crossOverPadding = const EdgeInsets.all(3),
    this.hasActivitiesDotPadding = const EdgeInsets.all(0),
    this.activityTextContentPadding = const EdgeInsets.all(3),
    this.monthPreview = const MonthPreviewLayout(),
  });
}

class MonthCalendarLayoutMedium extends MonthCalendarLayout {
  const MonthCalendarLayoutMedium({
    MonthPreviewLayout? monthPreviewLayout,
    int? monthContentFlex,
    int? monthListPreviewFlex,
  }) : super(
            monthContentFlex: monthContentFlex ?? 620,
            monthListPreviewFlex: monthListPreviewFlex ?? 344,
            monthHeadingHeight: 48,
            dayRadius: 12,
            dayRadiusHighlighted: 14,
            dayBorderWidth: 2,
            dayBorderWidthHighlighted: 6,
            dayHeaderHeight: 28,
            dayHeadingFontSize: 20,
            weekNumberWidth: 36,
            hasActivitiesDotRadius: 5,
            dayViewMargin: const EdgeInsets.all(4),
            dayViewMarginHighlighted: const EdgeInsets.all(1),
            dayViewPadding: const EdgeInsets.all(0),
            dayViewPaddingHighlighted: const EdgeInsets.all(3),
            dayHeaderPadding: const EdgeInsets.only(left: 6, right: 6, top: 6),
            dayContainerPadding:
                const EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 6),
            hasActivitiesDotPadding: const EdgeInsets.only(right: 6, top: 6),
            activityTextContentPadding: const EdgeInsets.all(4),
            monthPreview:
                monthPreviewLayout ?? const MonthPreviewLayoutMedium());
}

class MonthCalendarLayoutLarge extends MonthCalendarLayoutMedium {
  const MonthCalendarLayoutLarge()
      : super(
          monthContentFlex: 932,
          monthListPreviewFlex: 620,
          monthPreviewLayout: const MonthPreviewLayoutLarge(),
        );
}
