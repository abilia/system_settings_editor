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
          selector: const SelectorLayoutLarge(),
          menuPage: const MenuPageLayoutLarge(),
          fontSize: const FontSizeLarge(),
        );
}
