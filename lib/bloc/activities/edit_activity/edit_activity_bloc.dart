import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import 'package:seagull/repository/timezone.dart' as tz;

part 'edit_activity_event.dart';
part 'edit_activity_state.dart';

class EditActivityBloc extends Bloc<EditActivityEvent, EditActivityState> {
  final ActivitiesBloc activitiesBloc;
  final ClockBloc clockBloc;
  final MemoplannerSettingBloc memoplannerSettingBloc;

  EditActivityBloc(
    ActivityDay activityDay, {
    @required this.activitiesBloc,
    @required this.clockBloc,
    @required this.memoplannerSettingBloc,
  })  : assert(activityDay != null),
        assert(activitiesBloc != null),
        super(
          StoredActivityState(
              activityDay.activity,
              activityDay.activity.fullDay
                  ? TimeInterval(startDate: activityDay.activity.startTime)
                  : TimeInterval.fromDateTime(
                      activityDay.activity.startClock(activityDay.day),
                      activityDay.activity.hasEndTime
                          ? activityDay.activity.endClock(activityDay.day)
                          : null),
              activityDay.day),
        );

  EditActivityBloc.newActivity({
    @required this.activitiesBloc,
    @required this.clockBloc,
    @required this.memoplannerSettingBloc,
    @required DateTime day,
    BasicActivityDataItem basicActivityData,
  })  : assert(day != null),
        assert(activitiesBloc != null),
        super(
          UnstoredActivityState(
            basicActivityData == null
                ? Activity.createNew(
                    title: '',
                    startTime: day,
                    timezone: tz.local.name,
                    alarmType:
                        memoplannerSettingBloc.state.defaultAlarmTypeSetting,
                  )
                : basicActivityData.toActivity(
                    timezone: tz.local.name, day: day),
            basicActivityData == null
                ? TimeInterval(startDate: day)
                : basicActivityData.toTimeInterval(startDate: day),
          ),
        );

  static const NO_GO_ERRORS = {
    SaveError.NO_START_TIME,
    SaveError.NO_TITLE_OR_IMAGE,
    SaveError.START_TIME_BEFORE_NOW,
    SaveError.NO_RECURRING_DAYS,
  };

  Set<SaveError> saveErrors(SaveActivity event) => {
        if (!state.hasTitleOrImage) SaveError.NO_TITLE_OR_IMAGE,
        if (!state.hasStartTime) SaveError.NO_START_TIME,
        if (state.startTimeBeforeNow(clockBloc.state))
          if (!memoplannerSettingBloc.state.activityTimeBeforeCurrent)
            SaveError.START_TIME_BEFORE_NOW
          else if (!event.warningConfirmed)
            SaveError.UNCONFIRMED_START_TIME_BEFORE_NOW,
        if (state.emptyRecurringData) SaveError.NO_RECURRING_DAYS,
        if (state.storedRecurring && event is! SaveRecurringActivity)
          SaveError.STORED_RECURRING,
        if (state.hasStartTime &&
            !event.warningConfirmed &&
            !state.unchangedTime &&
            activitiesBloc.state.anyConflictWith(state._activityToStore()))
          SaveError.UNCONFIRMED_ACTIVITY_CONFLICT,
      };

  @override
  Stream<EditActivityState> mapEventToState(
    EditActivityEvent event,
  ) async* {
    if (event is ReplaceActivity) {
      yield state.copyWith(event.activity);
    }
    if (event is ChangeDate) {
      yield* _mapChangeDateToState(event);
    }
    if (event is AddOrRemoveReminder) {
      yield* _mapAddOrRemoveReminderToState(event.reminder.inMilliseconds);
    }
    if (event is SaveActivity) {
      yield* _mapSaveActivityToState(state, event);
    }
    if (event is ChangeTimeInterval) {
      yield state.copyWith(
        state.activity,
        timeInterval: state.timeInterval.copyWith(
          startTime: event.startTime,
          endTime: event.endTime ?? event.startTime,
        ),
      );
    }
    if (event is ImageSelected) {
      yield state.copyWith(
        state.activity.copyWith(
          fileId: event.imageId,
          icon: event.path,
        ),
      );
    }
    if (event is ChangeInfoItemType) {
      yield* _mapChangeInfoItemTypeToState(event);
    }
  }

  Stream<EditActivityState> _mapAddOrRemoveReminderToState(
    int reminder,
  ) async* {
    final reminders = state.activity.reminderBefore.toSet();
    if (!reminders.add(reminder)) {
      reminders.remove(reminder);
    }
    yield state.copyWith(state.activity.copyWith(reminderBefore: reminders));
  }

  Stream<EditActivityState> _mapSaveActivityToState(
    EditActivityState state,
    SaveActivity event,
  ) async* {
    if (state is StoredActivityState && state.unchanged) {
      yield state.saveSucess();
      return;
    }

    final errors = saveErrors(event);
    if (errors.isNotEmpty) {
      yield state.failSave(errors);
      return;
    }

    final activity = state._activityToStore();

    if (state is UnstoredActivityState) {
      activitiesBloc.add(AddActivity(activity));
    } else if (event is SaveRecurringActivity) {
      activitiesBloc.add(
        UpdateRecurringActivity(
          ActivityDay(activity, event.day),
          event.applyTo,
        ),
      );
    } else {
      activitiesBloc.add(UpdateActivity(activity));
    }

    yield StoredActivityState(
      activity,
      state.timeInterval,
      state is StoredActivityState ? state.day : activity.startTime.onlyDays(),
    ).saveSucess();
  }

  Stream<EditActivityState> _mapChangeDateToState(ChangeDate event) async* {
    final newTimeInterval = state.timeInterval.copyWith(startDate: event.date);
    if (state.activity.recurs.yearly) {
      yield state.copyWith(
        state.activity.copyWith(recurs: Recurs.yearly(event.date)),
        timeInterval: newTimeInterval,
      );
    } else if (state.activity.isRecurring &&
        state.activity.recurs.end.isDayBefore(event.date)) {
      yield state.copyWith(
        state.activity.copyWith(
          recurs: state.activity.recurs.changeEnd(event.date),
        ),
        timeInterval: newTimeInterval,
      );
    } else {
      yield state.copyWith(
        state.activity,
        timeInterval: newTimeInterval,
      );
    }
  }

  Stream<EditActivityState> _mapChangeInfoItemTypeToState(
      ChangeInfoItemType event) async* {
    final oldInfoItem = state.activity.infoItem;
    final oldInfoItemType = oldInfoItem.runtimeType;
    final newInfoType = event.infoItemType;
    if (newInfoType == oldInfoItemType) return;
    final infoItems = Map.fromEntries(state.infoItems.entries);
    infoItems[oldInfoItemType] = oldInfoItem;

    yield state.copyWith(
      state.activity.copyWith(
        infoItem: infoItems[newInfoType] ?? _newInfoItem(newInfoType),
      ),
      infoItems: infoItems,
    );
  }

  InfoItem _newInfoItem(Type infoItemType) {
    switch (infoItemType) {
      case NoteInfoItem:
        return NoteInfoItem();
      case Checklist:
        return Checklist();
      default:
        return InfoItem.none;
    }
  }
}
