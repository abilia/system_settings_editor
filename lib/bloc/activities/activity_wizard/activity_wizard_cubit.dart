import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'activity_wizard_state.dart';

class ActivityWizardCubit extends Cubit<ActivityWizardState> {
  final ActivitiesBloc activitiesBloc;
  final EditActivityCubit editActivityCubit;
  final MemoplannerSettingsState settings;
  final ClockBloc clockBloc;
  final bool edit;

  bool get allowActivityTimeBeforeCurrent =>
      settings.settings.addActivity.allowPassedStartTime;

  StreamSubscription<EditActivityState>? _editActivityCubitSubscription;

  ActivityWizardCubit.newActivity({
    required this.activitiesBloc,
    required this.editActivityCubit,
    required this.clockBloc,
    required this.settings,
  })  : edit = false,
        super(
          ActivityWizardState(
            0,
            settings.addActivityType == NewActivityMode.editView
                ? UnmodifiableListView(
                    [
                      WizardStep.advance,
                    ],
                  )
                : _generateWizardSteps(
                    stepByStep: settings.settings.stepByStep,
                    addRecurringActivity:
                        settings.settings.addActivity.addRecurringActivity,
                    activity: editActivityCubit.state.activity,
                  ),
          ),
        ) {
    if (settings.addActivityType == NewActivityMode.stepByStep) {
      _editActivityCubitSubscription = editActivityCubit.stream.listen(
        (event) {
          final newSteps = _generateWizardSteps(
            stepByStep: settings.settings.stepByStep,
            addRecurringActivity:
                settings.settings.addActivity.addRecurringActivity,
            activity: event.activity,
          );
          if (newSteps != state.steps) {
            emit(state.copyWith(newSteps: newSteps));
          }
        },
      );
    }
  }

  static List<WizardStep> _generateWizardSteps({
    required StepByStepSettings stepByStep,
    required bool addRecurringActivity,
    required Activity activity,
  }) =>
      [
        if (stepByStep.datePicker) WizardStep.date,
        if (stepByStep.title) WizardStep.title,
        if (stepByStep.image) WizardStep.image,
        if (stepByStep.type) WizardStep.type,
        if (stepByStep.availability) WizardStep.availableFor,
        if (stepByStep.checkable) WizardStep.checkable,
        if (stepByStep.removeAfter) WizardStep.deleteAfter,
        if (!activity.fullDay) WizardStep.time,
        if (!activity.fullDay && stepByStep.alarm) WizardStep.alarm,
        if (stepByStep.checklist || stepByStep.notes)
          WizardStep.connectedFunction,
        if (stepByStep.reminders && !activity.fullDay) WizardStep.reminder,
        if (addRecurringActivity) WizardStep.recurring,
        if (activity.recurs.weekly) WizardStep.recursWeekly,
        if (activity.recurs.monthly) WizardStep.recursMonthly,
        if (activity.isRecurring && !activity.recurs.hasNoEnd)
          WizardStep.endDate,
      ];

  ActivityWizardCubit.edit({
    required this.activitiesBloc,
    required this.editActivityCubit,
    required this.clockBloc,
    required this.settings,
  })  : edit = true,
        super(ActivityWizardState(0, const [WizardStep.advance]));

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

    editActivityCubit.activitySaved(activity);
    return state.saveSucess();
  }

  @override
  Future<void> close() async {
    await _editActivityCubitSubscription?.cancel();
    return super.close();
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
        if (!hasTitleOrImage) SaveError.noTitleOrImage,
        if (!hasStartTime) SaveError.noStartTime,
        if (startTimeBeforeNow(now))
          if (!allowActivityTimeBeforeCurrent)
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
            activity.recurs.end.isBefore(timeInterval.startDate))
          SaveError.endDateBeforeStart
      };

  SaveError? stepErrors({
    required ActivityWizardState wizState,
    required DateTime now,
    required bool allowActivityTimeBeforeCurrent,
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
          if (!allowActivityTimeBeforeCurrent) {
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
