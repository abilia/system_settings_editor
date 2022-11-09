import 'dart:async';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

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
    required AddActivitySettings addActivitySettings,
    bool showCategories = true,
  }) {
    if (addActivitySettings.mode == AddActivityMode.editView) {
      return ActivityWizardCubit.newAdvanced(
        activitiesBloc: activitiesBloc,
        editActivityCubit: editActivityCubit,
        clockBloc: clockBloc,
        allowPassedStartTime: addActivitySettings.general.allowPassedStartTime,
      );
    }
    return ActivityWizardCubit.newStepByStep(
      activitiesBloc: activitiesBloc,
      editActivityCubit: editActivityCubit,
      clockBloc: clockBloc,
      allowPassedStartTime: addActivitySettings.general.allowPassedStartTime,
      stepByStep: addActivitySettings.stepByStep,
      addRecurringActivity: addActivitySettings.general.addRecurringActivity,
      showCategories: showCategories,
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
    required bool showCategories,
  }) : super(
          WizardState(
            0,
            _generateWizardSteps(
              stepByStep: stepByStep,
              addRecurringActivity: addRecurringActivity,
              showCategories: showCategories,
              editState: editActivityCubit.state,
            ),
          ),
        ) {
    _editActivityCubitSubscription = editActivityCubit.stream.listen(
      (event) {
        final newSteps = _generateWizardSteps(
          stepByStep: stepByStep,
          addRecurringActivity: addRecurringActivity,
          showCategories: showCategories,
          editState: event,
        );
        if (newSteps != state.steps) {
          emit(state.copyWith(newSteps: newSteps, saveErrors: {}));
        }
      },
    );
  }

  static List<WizardStep> _generateWizardSteps({
    required StepByStepSettings stepByStep,
    required bool addRecurringActivity,
    required bool showCategories,
    required EditActivityState editState,
  }) =>
      [
        if (stepByStep.title) WizardStep.title,
        if (stepByStep.image) WizardStep.image,
        if (stepByStep.date) WizardStep.date,
        if (stepByStep.fullDay) WizardStep.fullDay,
        if (!editState.activity.fullDay) WizardStep.time,
        if (!editState.activity.fullDay && showCategories) WizardStep.category,
        if (stepByStep.checkable) WizardStep.checkable,
        if (stepByStep.removeAfter) WizardStep.deleteAfter,
        if (stepByStep.availability) WizardStep.availableFor,
        if (!editState.activity.fullDay && stepByStep.alarm) WizardStep.alarm,
        if (stepByStep.reminders && !editState.activity.fullDay)
          WizardStep.reminder,
        if (addRecurringActivity) WizardStep.recurring,
        if (editState.activity.recurs.weekly) WizardStep.recursWeekly,
        if (editState.activity.recurs.monthly) WizardStep.recursMonthly,
        if (editState.activity.isRecurring && !editState.recursWithNoEnd)
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
  Future<void> next({
    bool warningConfirmed = false,
    SaveRecurring? saveRecurring,
  }) async {
    if (state.isLastStep) {
      return emit(
        await _saveActivity(
          editActivityCubit.state,
          beforeNowWarningConfirmed:
              warningConfirmed || !state.steps.contains(WizardStep.advance),
          conflictWarningConfirmed: warningConfirmed,
          saveRecurring: saveRecurring,
        ),
      );
    }

    final error = editActivityCubit.state.stepError(
      wizState: state,
      now: clockBloc.state,
      allowPassedStartTime: allowPassedStartTime,
      warningConfirmed: warningConfirmed,
    );

    if (error != null) {
      return emit(state.failSave({error}));
    }

    emit(state.copyWith(
      newStep: (state.step + 1),
      saveErrors: {},
      showDialogWarnings: true,
    ));
  }

  @override
  void removeCorrectedErrors() {
    if (state.saveErrors.isEmpty || !state.isLastStep) {
      return;
    }

    final errors = editActivityCubit.state
        .saveErrors(
          beforeNowWarningConfirmed: false,
          conflictWarningConfirmed: false,
          saveRecurringDefined: false,
          allowPassedStartTime: allowPassedStartTime,
          activities: [],
          now: clockBloc.state,
        )
        //Ensures that errors can only be removed, not added
        .intersection(state.saveErrors);

    emit(state.copyWith(saveErrors: errors, showDialogWarnings: false));
  }

  Future<WizardState> _saveActivity(
    EditActivityState editState, {
    required bool beforeNowWarningConfirmed,
    required bool conflictWarningConfirmed,
    required SaveRecurring? saveRecurring,
  }) async {
    if (editState is StoredActivityState && editState.unchanged) {
      return state.saveSuccess();
    }

    final activity = editState.activityToStore();

    final errors = editState.saveErrors(
      beforeNowWarningConfirmed: beforeNowWarningConfirmed,
      conflictWarningConfirmed: conflictWarningConfirmed,
      saveRecurringDefined: saveRecurring != null,
      allowPassedStartTime: allowPassedStartTime,
      activities: await activitiesBloc.activityRepository.allBetween(
          activity.startTime.onlyDays(),
          activity.startTime.onlyDays().nextDay()),
      now: clockBloc.state,
    );
    if (errors.isNotEmpty) {
      return state.failSave(errors);
    }

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
    return state.saveSuccess();
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
    required bool saveRecurringDefined,
    required bool allowPassedStartTime,
    required DateTime now,
    required Iterable<Activity> activities,
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
        if (storedRecurring && !saveRecurringDefined) SaveError.storedRecurring,
        if (hasStartTime &&
            !conflictWarningConfirmed &&
            !unchangedTime &&
            activities.anyConflictWith(activityToStore()))
          SaveError.unconfirmedActivityConflict,
        if (activity.isRecurring &&
            hasEndDate &&
            activity.recurs.end.isBefore(timeInterval.startDate))
          SaveError.endDateBeforeStart,
        if (activity.isRecurring && !hasEndDate) SaveError.noRecurringEndDate
      };

  SaveError? stepError({
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
      case WizardStep.date:
        if (startDateBeforeNow(now) && !allowPassedStartTime) {
          return SaveError.startTimeBeforeNow;
        }
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
