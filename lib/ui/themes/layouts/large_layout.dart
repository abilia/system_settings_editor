part of 'layout.dart';

class LargeLayout extends MediumLayout {
  const LargeLayout()
      : super(
          appBar: const LargeAppBarLayout(),
          actionButton: const LargeActionButtonLayout(),
          clockLayout: const LargeClockLayout(),
          fontSize: const LargeFontSize(),
        );
}
