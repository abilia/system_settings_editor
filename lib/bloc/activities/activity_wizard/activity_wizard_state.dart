part of 'activity_wizard_cubit.dart';

enum WizardStep {
  basic,
  name,
  image,
  date,
  type,
  checkable,
  available_for,
  delete_after,
  alarm,
  time,
  checklist,
  note,
}

class ActivityWizardState {
  final int step;
  final List<WizardStep> pages;
  final SaveError? currentError;
  const ActivityWizardState(
    this.step,
    this.pages, [
    this.currentError,
  ]);

  bool get isFirstStep => step == 0;

  bool get isLastStep => step >= pages.length - 1;

  ActivityWizardState copyWith({
    required int newStep,
    SaveError? error,
  }) =>
      ActivityWizardState(
        newStep,
        pages,
        error,
      );

  WizardStep get currentPage => pages[step];
}

extension ErrorTranslation on SaveError {
  String toMessage(Translated translate) {
    switch (this) {
      case SaveError.NO_START_TIME:
        return translate.missingStartTime;
      case SaveError.NO_TITLE_OR_IMAGE:
        return translate.missingTitleOrImage;
      case SaveError.START_TIME_BEFORE_NOW:
        return translate.startTimeBeforeNowError;
      case SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW:
        return translate.startTimeBeforeNowWarning;
      case SaveError.UNCONFIRMED_ACTIVITY_CONFLICT:
        return translate.conflictWarning;
      default:
        return '';
    }
  }
}
