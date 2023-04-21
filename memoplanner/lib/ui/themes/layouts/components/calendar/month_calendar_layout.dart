import 'package:memoplanner/ui/all.dart';

class MonthCalendarLayout {
  final double headingHeight, weekHeight, weekNumberWidth;

  final MonthPreviewLayout monthPreview;
  final MonthCalendarDayLayout day;

  const MonthCalendarLayout({
    this.headingHeight = 32,
    this.weekHeight = 40,
    this.weekNumberWidth = 24,
    this.monthPreview = const MonthPreviewLayout(),
    this.day = const MonthCalendarDayLayout(),
  });
}

class MonthCalendarLayoutMedium extends MonthCalendarLayout {
  const MonthCalendarLayoutMedium({
    MonthPreviewLayout? monthPreviewLayout,
    double? weekHeight,
  }) : super(
          headingHeight: 48,
          weekHeight: weekHeight ?? 104,
          weekNumberWidth: 36,
          monthPreview: monthPreviewLayout ?? const MonthPreviewLayoutMedium(),
          day: const MonthCalendarDayLayoutMedium(),
        );
}

class MonthCalendarLayoutLarge extends MonthCalendarLayoutMedium {
  const MonthCalendarLayoutLarge()
      : super(
          weekHeight: 156,
          monthPreviewLayout: const MonthPreviewLayoutLarge(),
        );
}
