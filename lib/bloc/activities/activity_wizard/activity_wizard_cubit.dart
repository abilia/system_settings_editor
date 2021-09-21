import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'activity_wizard_state.dart';

class ActivityWizardCubit extends Cubit<ActivityWizardState> {
  final ActivitiesBloc activitiesBloc;
  final EditActivityBloc editActivityBloc;
  final ClockBloc clockBloc;
  final bool allowActivityTimeBeforeCurrent;

  ActivityWizardCubit.newActivity({
    required this.activitiesBloc,
    required this.editActivityBloc,
    required this.clockBloc,
    required MemoplannerSettingsState settings,
  })  : allowActivityTimeBeforeCurrent = settings.activityTimeBeforeCurrent,
        super(
          ActivityWizardState(
            0,
            settings.addActivityType == NewActivityMode.editView
                ? UnmodifiableListView(
                    [
                      if (settings.advancedActivityTemplate) WizardStep.basic,
                      WizardStep.advance,
                    ],
                  )
                : UnmodifiableListView(
                    [
                      if (settings.wizardTemplateStep) WizardStep.basic,
                      if (settings.wizardDatePickerStep) WizardStep.date,
                      if (settings.wizardImageStep) WizardStep.image,
                      if (settings.wizardTitleStep) WizardStep.title,
                      if (settings.wizardTypeStep) WizardStep.type,
                      if (settings.wizardAvailabilityType)
                        WizardStep.available_for,
                      if (settings.wizardCheckableStep) WizardStep.checkable,
                      if (settings.wizardRemoveAfterStep)
                        WizardStep.delete_after,
                      WizardStep.time,
                      if (settings.wizardAlarmStep) WizardStep.alarm,
                      if (settings.wizardChecklistStep ||
                          settings.wizardNotesStep)
                        WizardStep.note,
                      if (settings.wizardRemindersStep) WizardStep.reminder,
                      if (settings.activityRecurringEditable)
                        WizardStep.recurring,
                    ],
                  ),
          ),
        );

  ActivityWizardCubit.edit({
    required this.activitiesBloc,
    required this.editActivityBloc,
    required this.clockBloc,
    required this.allowActivityTimeBeforeCurrent,
  }) : super(
            ActivityWizardState(0, UnmodifiableListView([WizardStep.advance])));

  void next({
    bool warningConfirmed = false,
    SaveRecurring? saveRecurring,
  }) {
    if (state.isLastStep) {
      return emit(
        _saveActivity(
          editActivityBloc.state,
          beforeNowWarningConfirmed:
              warningConfirmed || !state.steps.contains(WizardStep.advance),
          conflictWarningConfirmed: warningConfirmed,
          saveRecurring: saveRecurring,
        ),
      );
    }

    final error = editActivityBloc.state.stepErrors(
      step: state.currentStep,
      now: clockBloc.state,
      allowActivityTimeBeforeCurrent: allowActivityTimeBeforeCurrent,
      warningConfirmed: warningConfirmed,
    );

    if (error != null) {
      return emit(state.failSave({error}));
    }

    emit(state.copyWith(newStep: (state.step + 1)));
  }

  void previous() => emit(state.copyWith(newStep: (state.step - 1)));

  ActivityWizardState _saveActivity(
    EditActivityState editState, {
    required bool beforeNowWarningConfirmed,
    required bool conflictWarningConfirmed,
    required SaveRecurring? saveRecurring,
  }) {
    if (editState is StoredActivityState && editState.unchanged) {
      return state.saveSucess();
    }

    final errors = editState.saveErrors(
      beforeNowWarningConfirmed: beforeNowWarningConfirmed,
      conflictWarningConfirmed: conflictWarningConfirmed,
      saveReccuringDefined: saveRecurring != null,
      allowActivityTimeBeforeCurrent: allowActivityTimeBeforeCurrent,
      activitiesState: activitiesBloc.state,
      now: clockBloc.state,
    );
    if (errors.isNotEmpty) {
      return state.failSave(errors);
    }

    final activity = editState.activityToStore();

    if (editState is UnstoredActivityState) {
      activitiesBloc.add(AddActivity(activity));
    } else if (saveRecurring != null) {
      activitiesBloc.add(
        UpdateRecurringActivity(
          ActivityDay(activity, saveRecurring.day),
          saveRecurring.applyTo,
        ),
      );
    } else {
      activitiesBloc.add(UpdateActivity(activity));
    }

    editActivityBloc.add(ActivitySavedSuccessfully(activity));
    return state.saveSucess();
  }
}

class SaveRecurring {
  final ApplyTo applyTo;
  final DateTime day;
  const SaveRecurring(this.applyTo, this.day);
}

extension SaveErrorExtension on EditActivityState {
  Set<SaveError> saveErrors({
    required bool beforeNowWarningConfirmed,
    required bool conflictWarningConfirmed,
    required bool saveReccuringDefined,
    required bool allowActivityTimeBeforeCurrent,
    required DateTime now,
    required ActivitiesState activitiesState,
  }) =>
      {
        if (!hasTitleOrImage) SaveError.NO_TITLE_OR_IMAGE,
        if (!hasStartTime) SaveError.NO_START_TIME,
        if (startTimeBeforeNow(now))
          if (!allowActivityTimeBeforeCurrent)
            SaveError.START_TIME_BEFORE_NOW
          else if (!beforeNowWarningConfirmed)
            SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW,
        if (emptyRecurringData) SaveError.NO_RECURRING_DAYS,
        if (storedRecurring && !saveReccuringDefined)
          SaveError.STORED_RECURRING,
        if (hasStartTime &&
            !conflictWarningConfirmed &&
            !unchangedTime &&
            activitiesState.anyConflictWith(activityToStore()))
          SaveError.UNCONFIRMED_ACTIVITY_CONFLICT,
      };

  SaveError? stepErrors({
    required WizardStep step,
    required DateTime now,
    required bool allowActivityTimeBeforeCurrent,
    required bool warningConfirmed,
  }) {
    switch (step) {
      case WizardStep.title:
        if (!hasTitleOrImage) return SaveError.NO_TITLE_OR_IMAGE;
        break;
      case WizardStep.time:
        if (!hasStartTime) return SaveError.NO_START_TIME;
        if (startTimeBeforeNow(now)) {
          if (!allowActivityTimeBeforeCurrent) {
            return SaveError.START_TIME_BEFORE_NOW;
          } else if (!warningConfirmed) {
            return SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW;
          }
        }
        break;
      case WizardStep.recurring:
        if (emptyRecurringData) return SaveError.NO_RECURRING_DAYS;
        break;
      default:
    }
  }
}
