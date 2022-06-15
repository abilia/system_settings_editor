part of 'layout.dart';

class LargeLayout extends MediumLayout {
  const LargeLayout()
      : super(
          appBar: const AppBarLayoutLarge(),
          actionButton: const ActionButtonLayoutLarge(),
          templates: const LayoutTemplatesLarge(),
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
          menuPage: const MenuPageLayoutLarge(),
          fontSize: const FontSizeLarge(),
        );
}
