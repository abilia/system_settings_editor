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
