import 'dart:async';
import 'dart:collection';

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
  final MemoplannerSettingsState settings;
  final ClockBloc clockBloc;

  bool get allowActivityTimeBeforeCurrent => settings.activityTimeBeforeCurrent;

  StreamSubscription<EditActivityState>? _activityBlocSubscription;

  ActivityWizardCubit.newActivity({
    required this.activitiesBloc,
    required this.editActivityBloc,
    required this.clockBloc,
    required this.settings,
  }) : super(
          ActivityWizardState(
            0,
            settings.addActivityType == NewActivityMode.editView
                ? UnmodifiableListView(
                    [
                      if (settings.advancedActivityTemplate) WizardStep.basic,
                      WizardStep.advance,
                    ],
                  )
                : _generateWizardSteps(
                    settings, editActivityBloc.state.activity),
          ),
        ) {
    if (settings.addActivityType == NewActivityMode.stepByStep) {
      _activityBlocSubscription = editActivityBloc.stream.listen(
        (event) {
          final newSteps = _generateWizardSteps(settings, event.activity);
          if (newSteps != state.steps) {
            emit(state.copyWith(newSteps: newSteps));
          }
        },
      );
    }
  }

  static List<WizardStep> _generateWizardSteps(
    MemoplannerSettingsState settings,
    Activity activity,
  ) =>
      [
        if (settings.wizardTemplateStep) WizardStep.basic,
        if (settings.wizardDatePickerStep) WizardStep.date,
        if (settings.wizardTitleStep) WizardStep.title,
        if (settings.wizardImageStep) WizardStep.image,
        if (settings.wizardTypeStep) WizardStep.type,
        if (settings.wizardAvailabilityType) WizardStep.available_for,
        if (settings.wizardCheckableStep) WizardStep.checkable,
        if (settings.wizardRemoveAfterStep) WizardStep.delete_after,
        if (!activity.fullDay) WizardStep.time,
        if (!activity.fullDay && settings.wizardAlarmStep) WizardStep.alarm,
        if (settings.wizardChecklistStep || settings.wizardNotesStep)
          WizardStep.connectedFunction,
        if (settings.wizardRemindersStep && !activity.fullDay)
          WizardStep.reminder,
        if (settings.activityRecurringEditable) WizardStep.recurring,
        if (activity.recurs.weekly) WizardStep.recursWeekly,
        if (activity.recurs.monthly) WizardStep.recursMonthly,
        if (activity.isRecurring && !activity.recurs.hasNoEnd)
          WizardStep.endDate,
      ];

  ActivityWizardCubit.edit({
    required this.activitiesBloc,
    required this.editActivityBloc,
    required this.clockBloc,
    required this.settings,
  }) : super(ActivityWizardState(0, [WizardStep.advance]));

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

    editActivityBloc.add(ActivitySavedSuccessfully(activity));
    return state.saveSucess();
  }

  @override
  Future<void> close() async {
    await _activityBlocSubscription?.cancel();
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
        if (activity.isRecurring &&
            activity.recurs.end.isBefore(activity.startTime))
          SaveError.END_DATE_BEFORE_START
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
          return SaveError.NO_TITLE_OR_IMAGE;
        }
        break;
      case WizardStep.image:
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
      case WizardStep.recursWeekly:
      case WizardStep.recursMonthly:
        if (emptyRecurringData) return SaveError.NO_RECURRING_DAYS;

        break;
      case WizardStep.endDate:
        if (activity.recurs.end.isBefore(activity.startTime)) {
          return SaveError.END_DATE_BEFORE_START;
        }
        break;
      default:
    }
  }
}
