import 'dart:async';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityWizardCubit extends WizardCubit {
  final ActivitiesBloc activitiesBloc;
  final EditActivityCubit editActivityCubit;
  final ClockBloc clockBloc;
  final bool allowPassedStartTime;

  StreamSubscription<EditActivityState>? _editActivityCubitSubscription;

  @visibleForTesting
  factory ActivityWizardCubit.newActivity({
    required ActivitiesBloc activitiesBloc,
    required EditActivityCubit editActivityCubit,
    required ClockBloc clockBloc,
    required AddActivitySettings settings,
  }) {
    if (settings.mode == AddActivityMode.editView) {
      return ActivityWizardCubit.newAdvanced(
        activitiesBloc: activitiesBloc,
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        allowPassedStartTime: settings.general.allowPassedStartTime,
      );
    }
    return ActivityWizardCubit.newStepByStep(
      activitiesBloc: activitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      allowPassedStartTime: settings.general.allowPassedStartTime,
      stepByStep: settings.stepByStep,
      addRecurringActivity: settings.general.addRecurringActivity,
    );
  }

  ActivityWizardCubit.newAdvanced({
    required this.activitiesBloc,
    required this.editActivityCubit,
    required this.clockBloc,
    required this.allowPassedStartTime,
  }) : super(WizardState(0, UnmodifiableListView([WizardStep.advance])));

  ActivityWizardCubit.newStepByStep({
    required this.activitiesBloc,
    required this.editActivityCubit,
    required this.clockBloc,
    required this.allowPassedStartTime,
    required StepByStepSettings stepByStep,
    required bool addRecurringActivity,
  }) : super(
          WizardState(
            0,
            _generateWizardSteps(
              stepByStep: stepByStep,
              addRecurringActivity: addRecurringActivity,
              activity: editActivityCubit.state.activity,
            ),
          ),
        ) {
    _editActivityCubitSubscription = editActivityCubit.stream.listen(
      (event) {
        final newSteps = _generateWizardSteps(
          stepByStep: stepByStep,
          addRecurringActivity: addRecurringActivity,
          activity: event.activity,
        );
        if (newSteps != state.steps) {
          emit(state.copyWith(newSteps: newSteps));
        }
      },
    );
  }

  static List<WizardStep> _generateWizardSteps({
    required StepByStepSettings stepByStep,
    required bool addRecurringActivity,
    required Activity activity,
  }) =>
      [
        if (stepByStep.title) WizardStep.title,
        if (stepByStep.image) WizardStep.image,
        if (stepByStep.datePicker) WizardStep.date,
        if (stepByStep.type) WizardStep.type,
        if (!activity.fullDay) WizardStep.time,
        if (stepByStep.checkable) WizardStep.checkable,
        if (stepByStep.removeAfter) WizardStep.deleteAfter,
        if (stepByStep.availability) WizardStep.availableFor,
        if (!activity.fullDay && stepByStep.alarm) WizardStep.alarm,
        if (stepByStep.reminders && !activity.fullDay) WizardStep.reminder,
        if (addRecurringActivity) WizardStep.recurring,
        if (activity.recurs.weekly) WizardStep.recursWeekly,
        if (activity.recurs.monthly) WizardStep.recursMonthly,
        if (activity.isRecurring && !activity.recurs.hasNoEnd)
          WizardStep.endDate,
        if (stepByStep.checklist || stepByStep.notes)
          WizardStep.connectedFunction,
      ];

  ActivityWizardCubit.edit({
    required this.activitiesBloc,
    required this.editActivityCubit,
    required this.clockBloc,
    required this.allowPassedStartTime,
  }) : super(WizardState(0, const [WizardStep.advance]));

  @override
  void next({
    bool warningConfirmed = false,
    SaveRecurring? saveRecurring,
  }) {
    if (state.isLastStep) {
      return emit(
        _saveActivity(
          editActivityCubit.state,
          beforeNowWarningConfirmed:
              warningConfirmed || !state.steps.contains(WizardStep.advance),
          conflictWarningConfirmed: warningConfirmed,
          saveRecurring: saveRecurring,
        ),
      );
    }

    final error = editActivityCubit.state.stepErrors(
      wizState: state,
      now: clockBloc.state,
      allowPassedStartTime: allowPassedStartTime,
      warningConfirmed: warningConfirmed,
    );

    if (error != null) {
      return emit(state.failSave({error}));
    }

    emit(state.copyWith(newStep: (state.step + 1)));
  }

  WizardState _saveActivity(
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
      allowPassedStartTime: allowPassedStartTime,
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

    editActivityCubit.activitySaved(activity);
    return state.saveSucess();
  }

  @override
  Future<void> close() async {
    await _editActivityCubitSubscription?.cancel();
    return super.close();
  }
}

extension SaveErrorExtension on EditActivityState {
  Set<SaveError> saveErrors({
    required bool beforeNowWarningConfirmed,
    required bool conflictWarningConfirmed,
    required bool saveReccuringDefined,
    required bool allowPassedStartTime,
    required DateTime now,
    required ActivitiesState activitiesState,
  }) =>
      {
        if (!hasTitleOrImage) SaveError.noTitleOrImage,
        if (!hasStartTime) SaveError.noStartTime,
        if (startTimeBeforeNow(now))
          if (!allowPassedStartTime)
            SaveError.startTimeBeforeNow
          else if (!beforeNowWarningConfirmed)
            SaveError.unconfirmedStartTimeBeforeNow,
        if (emptyRecurringData) SaveError.noRecurringDays,
        if (storedRecurring && !saveReccuringDefined) SaveError.storedRecurring,
        if (hasStartTime &&
            !conflictWarningConfirmed &&
            !unchangedTime &&
            activitiesState.anyConflictWith(activityToStore()))
          SaveError.unconfirmedActivityConflict,
        if (activity.isRecurring &&
            hasEndDate &&
            activity.recurs.end.isBefore(timeInterval.startDate))
          SaveError.endDateBeforeStart,
        if (activity.isRecurring && !hasEndDate) SaveError.noRecurringEndDate
      };

  SaveError? stepErrors({
    required WizardState wizState,
    required DateTime now,
    required bool allowPassedStartTime,
    required bool warningConfirmed,
  }) {
    switch (wizState.currentStep) {
      case WizardStep.title:
        if (!hasTitleOrImage && !wizState.steps.contains(WizardStep.image)) {
          return SaveError.noTitleOrImage;
        }
        break;
      case WizardStep.image:
        if (!hasTitleOrImage) return SaveError.noTitleOrImage;
        break;
      case WizardStep.time:
        if (!hasStartTime) return SaveError.noStartTime;
        if (startTimeBeforeNow(now)) {
          if (!allowPassedStartTime) {
            return SaveError.startTimeBeforeNow;
          } else if (!warningConfirmed) {
            return SaveError.unconfirmedStartTimeBeforeNow;
          }
        }
        break;
      case WizardStep.recursWeekly:
      case WizardStep.recursMonthly:
        if (emptyRecurringData) return SaveError.noRecurringDays;

        break;
      case WizardStep.endDate:
        if (activity.recurs.end.isBefore(timeInterval.startDate)) {
          return SaveError.endDateBeforeStart;
        }
        break;
      default:
    }
    return null;
  }
}
