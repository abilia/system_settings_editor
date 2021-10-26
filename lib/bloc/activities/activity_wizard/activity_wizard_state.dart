part of 'activity_wizard_cubit.dart';

enum WizardStep {
  basic,
  advance,
  date,
  title,
  image,
  type,
  checkable,
  availableFor,
  deleteAfter,
  time,
  alarm,
  connectedFunction,
  reminder,
  recurring,
  recursWeekly,
  recursMonthly,
  endDate,
}

enum SaveError {
  noStartTime,
  noTitleOrImage,
  startTimeBeforeNow,
  unconfirmedStartTimeBeforeNow,
  unconfirmedActivityConflict,
  noRecurringDays,
  storedRecurring,
  endDateBeforeStart,
}

extension SaveErrors on Set<SaveError> {
  bool get mainPageErrors => any({
        SaveError.noTitleOrImage,
        SaveError.noStartTime,
        SaveError.startTimeBeforeNow,
      }.contains);

  bool get noGoErrors => any({
        SaveError.noStartTime,
        SaveError.noTitleOrImage,
        SaveError.startTimeBeforeNow,
        SaveError.noRecurringDays,
        SaveError.endDateBeforeStart,
      }.contains);
}

class ActivityWizardState extends Equatable {
  final int step;
  final UnmodifiableListView<WizardStep> steps;
  final Set<SaveError> saveErrors;
  final bool? sucessfullSave;

  ActivityWizardState(
    this.step,
    Iterable<WizardStep> steps, {
    this.saveErrors = const UnmodifiableSetView.empty(),
    this.sucessfullSave,
  }) : steps = UnmodifiableListView(steps);

  bool get isFirstStep => step == 0;
  bool get isLastStep => step >= steps.length - 1;
  WizardStep get currentStep => steps[step];

  ActivityWizardState copyWith({
    int? newStep,
    List<WizardStep>? newSteps,
  }) {
    newStep ??= step;
    newSteps ??= steps;
    return ActivityWizardState(newStep.clamp(0, newSteps.length - 1), newSteps);
  }

  ActivityWizardState failSave(Set<SaveError> saveErrors) =>
      ActivityWizardState(
        step,
        steps,
        saveErrors: saveErrors,
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
