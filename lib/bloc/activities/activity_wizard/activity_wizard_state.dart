part of 'activity_wizard_cubit.dart';

class ActivityWizardState {
  final int step;
  final List<WizardPage> pages;
  final Set<SaveError> currentErrors;
  const ActivityWizardState(this.step, this.pages,
      [this.currentErrors = const <SaveError>{}]);

  bool isFirstStep() {
    return step == 0;
  }

  bool isLastStep() {
    return step >= pages.length - 1;
  }

  ActivityWizardState copyWith({
    required int newStep,
    Set<SaveError> errors = const <SaveError>{},
  }) {
    return ActivityWizardState(newStep, pages, errors);
  }

  WizardPage currentPage() {
    return pages[step];
  }
}

extension ErrorTranslation on Set<SaveError> {
  String toMessage(Translated translate) {
    if (contains(SaveError.NO_TITLE_OR_IMAGE)) {
      return translate.missingTitleOrImage;
    } else if (contains(SaveError.NO_START_TIME)) {
      return translate.missingStartTime;
    } else if (contains(SaveError.START_TIME_BEFORE_NOW)) {
      return translate.startTimeBeforeNowError;
    } else if (contains(SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW)) {
      return translate.startTimeBeforeNowWarning;
    } else if (contains(SaveError.UNCONFIRMED_ACTIVITY_CONFLICT)) {
      return translate.conflictWarning;
    } else {
      throw Exception();
    }
  }
}
