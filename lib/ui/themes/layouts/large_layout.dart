part of 'layout.dart';

class LargeLayout extends MediumLayout {
  const LargeLayout()
      : super(
          appBar: const AppBarLayoutLarge(),
          actionButton: const ActionButtonLayoutLarge(),
          templates: const TemplatesLayoutLarge(),
          clockLayout: const ClockLayoutLarge(),
          photoCalendarLayout: const PhotoCalendarLayoutLarge(),
          activityPageLayout: const ActivityPageLayoutLarge(),
          checkListLayout: const ChecklistLayout(
            question: ChecklistQuestionLayoutLarge(),
            listPadding: EdgeInsets.all(24),
            addNewQButtonPadding: EdgeInsets.fromLTRB(18, 12, 18, 18),
            addNewQIconPadding: EdgeInsets.only(left: 22, right: 16),
          )
        );
}
