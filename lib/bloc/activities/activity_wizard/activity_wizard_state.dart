part of 'activity_wizard_cubit.dart';

enum WizardStep {
  basic,
  title,
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
  advance,
}

class ActivityWizardState {
  final int step;
  final List<WizardStep> pages;

  const ActivityWizardState(
    this.step,
    this.pages,
  );

  bool get isFirstStep => step == 0;

  bool get isLastStep => step >= pages.length - 1;

  ActivityWizardState copyWith({
    required int newStep,
  }) =>
      ActivityWizardState(newStep.clamp(0, pages.length - 1), pages);

  WizardStep get currentPage => pages[step];
}
