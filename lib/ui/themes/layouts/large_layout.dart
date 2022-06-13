part of 'layout.dart';

class LargeLayout extends MediumLayout {
  const LargeLayout()
      : super(
          appBar: const AppBarLayoutLarge(),
          actionButton: const ActionButtonLayoutLarge(),
          templates: const TemplatesLayoutLarge(),
          clockLayout: const ClockLayoutLarge(),
          photoCalendarLayout: const PhotoCalendarLayoutLarge(),
          displaySettings: const DisplaySettingsDialogLayoutLarge(),
          selector: const SelectorLayoutLarge(),
        );
}
