part of 'activity_wizard_cubit.dart';

enum WizardStep {
  basic,
  advance,
  date,
  title,
  image,
  type,
  checkable,
  available_for,
  delete_after,
  time,
  alarm,
  checklist,
  note,
  reminder,
  recurring,
}

enum SaveError {
  NO_START_TIME,
  NO_TITLE_OR_IMAGE,
  START_TIME_BEFORE_NOW,
  UNCONFIRMED_START_TIME_BEFORE_NOW,
  UNCONFIRMED_ACTIVITY_CONFLICT,
  NO_RECURRING_DAYS,
  STORED_RECURRING,
}

extension SaveErrors on Set<SaveError> {
  bool get mainPageErrors => any({
        SaveError.NO_TITLE_OR_IMAGE,
        SaveError.NO_START_TIME,
        SaveError.START_TIME_BEFORE_NOW,
      }.contains);

  bool get noGoErrors => any({
        SaveError.NO_START_TIME,
        SaveError.NO_TITLE_OR_IMAGE,
        SaveError.START_TIME_BEFORE_NOW,
        SaveError.NO_RECURRING_DAYS,
      }.contains);
}

class ActivityWizardState extends Equatable {
  final int step;
  final List<WizardStep> steps;
  final Set<SaveError> saveErrors;
  final bool? sucessfullSave;

  const ActivityWizardState(
    this.step,
    this.steps, {
    this.saveErrors = const UnmodifiableSetView.empty(),
    this.sucessfullSave,
  });

  bool get isFirstStep => step == 0;
  bool get isLastStep => step >= steps.length - 1;
  WizardStep get currentStep => steps[step];

  ActivityWizardState copyWith({
    required int newStep,
  }) =>
      ActivityWizardState(newStep.clamp(0, steps.length - 1), steps);

  ActivityWizardState failSave(Set<SaveError> saveErrors) =>
      ActivityWizardState(
        step,
        steps,
        saveErrors: UnmodifiableSetView(saveErrors),
        sucessfullSave: sucessfullSave == null
            ? false
            : null, // this ugly trick to force state change each failSave
      );

  ActivityWizardState saveSucess() => ActivityWizardState(
        step,
        steps,
        sucessfullSave: true,
      );

  @override
  List<Object?> get props => [step, steps, saveErrors, sucessfullSave];
}