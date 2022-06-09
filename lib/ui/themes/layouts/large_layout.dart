part of 'layout.dart';

class LargeLayout extends MediumLayout {
  const LargeLayout()
      : super(
          appBar: const AppBarLayoutLarge(),
          actionButton: const ActionButtonLayoutLarge(),
          clockLayout: const ClockLayoutLarge(),
          photoCalendarLayout: const PhotoCalendarLayoutLarge(),
        );
}
