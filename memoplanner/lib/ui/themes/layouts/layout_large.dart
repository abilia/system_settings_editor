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
          checklist: const ChecklistLayout(
            question: ChecklistQuestionLayoutLarge(),
            listPadding: EdgeInsets.all(24),
            addNewQButtonPadding: EdgeInsets.fromLTRB(18, 12, 18, 18),
            addNewQIconPadding: EdgeInsets.only(left: 22, right: 16),
          ),
          timerPage: const TimerPageLayoutLarge(),
          timepillar: const TimepillarLayoutLarge(),
          category: const CategoryLayoutLarge(),
          menuPage: const MenuPageLayoutLarge(),
          fontSize: const FontSizeLarge(),
          eventCard: const EventCardLayoutLarge(),
          borders: const BorderLayoutLarge(),
          alarmPage: const AlarmPageLayoutLarge(),
          weekCalendar: const WeekCalendarLayoutLarge(),
        );
}
