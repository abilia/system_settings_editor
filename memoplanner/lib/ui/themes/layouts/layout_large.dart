part of 'layout.dart';

class LargeLayout extends MediumLayout {
  const LargeLayout()
      : super(
          templates: const TemplatesLayoutLarge(),
          appBar: const AppBarLayoutLarge(),
          actionButton: const ActionButtonLayoutLarge(),
          clockLayout: const ClockLayoutLarge(),
          monthCalendar: const MonthCalendarLayoutLarge(),
          photoCalendarLayout: const PhotoCalendarLayoutLarge(),
          activityPage: const ActivityPageLayoutLarge(),
          checklist: const ChecklistLayoutLarge(),
          timerPage: const TimerPageLayoutLarge(),
          timepillar: const TimepillarLayoutLarge(),
          category: const CategoryLayoutLarge(),
          menuPage: const MenuPageLayoutLarge(),
          fontSize: const FontSizeLarge(),
          eventCard: const EventCardLayoutLarge(),
          borders: const BorderLayoutLarge(),
          alarmPage: const AlarmPageLayoutLarge(),
          weekCalendar: const WeekCalendarLayoutLarge(),
          libraryPage: const LibraryPageLayoutLarge(),
        );
}
