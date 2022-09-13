part of 'wizard_cubit.dart';

enum WizardStep {
  advance,
  date,
  title,
  image,
  fullDay,
  category,
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
  noRecurringEndDate,
}

extension SaveErrors on Set<SaveError> {
  bool get mainPageErrors => any({
        SaveError.noTitleOrImage,
        SaveError.noStartTime,
        SaveError.startTimeBeforeNow,
      }.contains);

  bool get recurringPageErrors => any({
        SaveError.noRecurringDays,
        SaveError.noRecurringEndDate,
      }.contains);

  bool get noGoErrors => any({
        SaveError.noStartTime,
        SaveError.noTitleOrImage,
        SaveError.startTimeBeforeNow,
        SaveError.noRecurringDays,
        SaveError.endDateBeforeStart,
        SaveError.noRecurringEndDate,
      }.contains);
}

class WizardState extends Equatable {
  final int step;
  final UnmodifiableListView<WizardStep> steps;
  final Set<SaveError> saveErrors;
  final bool? successfulSave;
  final bool showDialogWarnings;

  WizardState(
    this.step,
    Iterable<WizardStep> steps, {
    this.saveErrors = const UnmodifiableSetView.empty(),
    this.successfulSave,
    this.showDialogWarnings = true,
  }) : steps = UnmodifiableListView(steps);

  bool get isFirstStep => step == 0;
  bool get isLastStep => step >= steps.length - 1;
  WizardStep get currentStep => steps[step];

  WizardState copyWith({
    int? newStep,
    List<WizardStep>? newSteps,
    Set<SaveError>? saveErrors,
    bool? showDialogWarnings,
  }) {
    newStep ??= step;
    newSteps ??= steps;
    return WizardState(
      newStep.clamp(0, newSteps.length - 1),
      newSteps,
      saveErrors: saveErrors ?? this.saveErrors,
      showDialogWarnings: showDialogWarnings ?? this.showDialogWarnings,
    );
  }

  WizardState failSave(Set<SaveError> saveErrors) => WizardState(
        step,
        steps,
        saveErrors: saveErrors,
        successfulSave: successfulSave == null
            ? false
            : null, // this ugly trick to force state change each failSave
      );

  WizardState saveSuccess() => WizardState(
        step,
        steps,
        successfulSave: true,
      );

  @override
  List<Object?> get props => [step, steps, saveErrors, successfulSave];
}
