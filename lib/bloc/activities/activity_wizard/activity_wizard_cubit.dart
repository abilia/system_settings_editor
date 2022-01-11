import 'dart:async';
import 'dart:ui';

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
  final VoidCallback? onBack;

  bool get allowActivityTimeBeforeCurrent => settings.activityTimeBeforeCurrent;

  StreamSubscription<EditActivityState>? _editActivityCubitSubscription;

  ActivityWizardCubit.newActivity({
    required this.activitiesBloc,
    required this.editActivityCubit,
    required this.clockBloc,
    required this.settings,
    this.onBack,
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
                    settings, editActivityCubit.state.activity),
          ),
        ) {
    if (settings.addActivityType == NewActivityMode.stepByStep) {
      _editActivityCubitSubscription = editActivityCubit.stream.listen(
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
        if (settings.settings.wizard.datePicker) WizardStep.date,
        if (settings.settings.wizard.title) WizardStep.title,
        if (settings.settings.wizard.image) WizardStep.image,
        if (settings.settings.wizard.type) WizardStep.type,
        if (settings.settings.wizard.availability) WizardStep.availableFor,
        if (settings.settings.wizard.checkable) WizardStep.checkable,
        if (settings.settings.wizard.removeAfter) WizardStep.deleteAfter,
        if (!activity.fullDay) WizardStep.time,
        if (!activity.fullDay && settings.settings.wizard.alarm)
          WizardStep.alarm,
        if (settings.settings.wizard.checklist ||
            settings.settings.wizard.notes)
          WizardStep.connectedFunction,
        if (settings.settings.wizard.reminders && !activity.fullDay)
          WizardStep.reminder,
        if (settings.activityRecurringEditable) WizardStep.recurring,
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
    this.onBack,
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

  void previous() async {
    if (state.isFirstStep) {
      onBack?.call();
    } else {
      emit(state.copyWith(newStep: (state.step - 1)));
    }
  }

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
            activity.recurs.end.isBefore(activity.startTime))
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
        if (activity.recurs.end.isBefore(activity.startTime)) {
          return SaveError.endDateBeforeStart;
        }
        break;
      default:
    }
  }
}
