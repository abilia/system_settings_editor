part of 'layout.dart';

class LargeLayout extends MediumLayout {
  const LargeLayout()
      : super(
          appBar: const AppBarLayoutLarge(),
          actionButton: const ActionButtonLayoutLarge(),
          templates: const TemplatesLayoutLarge(),
          clockLayout: const ClockLayoutLarge(),
          monthCalendar: const MonthCalendarLayoutLarge(),
          photoCalendarLayout: const PhotoCalendarLayoutLarge(),
          timepillar: const TimepillarLayoutLarge(),
          category: const CategoryLayoutLarge(),
          menuPage: const MenuPageLayoutLarge(),
          fontSize: const FontSizeLarge(),
          eventCard: const EventCardLayoutLarge(),
        );
}
