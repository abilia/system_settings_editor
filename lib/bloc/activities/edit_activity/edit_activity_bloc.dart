import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'edit_activity_event.dart';
part 'edit_activity_state.dart';

class EditActivityBloc extends Bloc<EditActivityEvent, EditActivityState> {
  final ActivityDay activityDay;
  final TimeInterval timeInterval;
  Activity get activity => activityDay.activity;
  DateTime get day => activityDay.day;
  final ActivitiesBloc activitiesBloc;
  final bool created;

  EditActivityBloc(this.activityDay, {@required this.activitiesBloc})
      : created = false,
        timeInterval = activityDay.activity.fullDay
            ? TimeInterval.empty()
            : TimeInterval.fromDateTime(
                activityDay.activity.startClock(activityDay.day),
                activityDay.activity.hasEndTime
                    ? activityDay.activity.endClock(activityDay.day)
                    : null),
        assert(activityDay != null);

  EditActivityBloc.newActivity({
    @required this.activitiesBloc,
    @required DateTime day,
  })  : created = true,
        timeInterval = TimeInterval(null, null),
        assert(day != null),
        activityDay = ActivityDay(
            Activity.createNew(
              title: '',
              startTime: day.nextHalfHour(),
              timezone: day.timeZoneName,
            ),
            day.onlyDays());
  @override
  EditActivityState get initialState => created
      ? UnstoredActivityState(activity, timeInterval)
      : StoredActivityState(activity, timeInterval, day);

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
    if (event is ChangeStartTime) {
      yield* _mapChangeStartTimeToState(event);
    }
    if (event is ChangeEndTime) {
      yield* _mapChangeEndTimeToState(event);
    }
    if (event is AddOrRemoveReminder) {
      yield* _mapAddOrRemoveReminderToState(event.reminder.inMilliseconds);
    }
    if (event is SaveActivity) {
      if (state.canSave) {
        yield* _mapSaveActivityToState(state, event);
      } else {
        yield state._failSave();
      }
    }
    if (event is ImageSelected) {
      yield state.copyWith(
          state.activity.copyWith(
            fileId: event.imageId,
            icon: event.path,
          ),
          newImage: event.newImage);
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

  Stream<StoredActivityState> _mapSaveActivityToState(
    EditActivityState state,
    SaveActivity event,
  ) async* {
    var activity = state.activity;
    if (this.activity == activity && timeInterval == state.timeInterval) return;
    if (activity.fullDay) {
      activity = activity.copyWith(
        startTime: activity.startTime.onlyDays(),
        alarmType: NO_ALARM,
        reminderBefore: [],
      );
    } else {
      final startTime =
          activity.startTime.withTime(state.timeInterval.startTime);
      final duration = state.timeInterval.endTimeSet
          ? _getDuration(startTime, state.timeInterval.endTime)
          : Duration.zero;
      activity = activity.copyWith(
        startTime: startTime,
        duration: duration,
      );
    }

    if (state is UnstoredActivityState) {
      activitiesBloc.add(AddActivity(activity));
    } else if (event is SaveRecurringActivity) {
      activitiesBloc.add(UpdateRecurringActivity(
        ActivityDay(activity, event.day),
        event.applyTo,
      ));
    } else {
      activitiesBloc.add(UpdateActivity(activity));
    }
    yield StoredActivityState(
        activity,
        state.timeInterval,
        state is StoredActivityState
            ? state.day
            : activity.startTime.onlyDays());
  }

  Stream<EditActivityState> _mapChangeDateToState(ChangeDate event) async* {
    yield state.copyWith(state.activity.copyWith(
      startTime: event.date,
    ));
  }

  Stream<EditActivityState> _mapChangeStartTimeToState(
      ChangeStartTime event) async* {
    // Move end time if start time changes
    if (state.timeInterval.startTimeSet && state.timeInterval.endTimeSet) {
      final newEndTime = _calculateNewEndTime(event);
      yield (state.copyWith(state.activity,
          timeInterval:
              TimeInterval(event.time, TimeOfDay.fromDateTime(newEndTime))));
    } else {
      yield state.copyWith(state.activity,
          timeInterval: TimeInterval(event.time, state.timeInterval.endTime));
    }
  }

  DateTime _calculateNewEndTime(ChangeStartTime event) {
    final activityStartTime = state.activity.startTime;
    final oldStart = activityStartTime.withTime(state.timeInterval.startTime);
    final newStart = activityStartTime.withTime(event.time);
    final diff = newStart.difference(oldStart);
    final endDate = activityStartTime.withTime(state.timeInterval.endTime);
    return endDate.add(diff);
  }

  Stream<EditActivityState> _mapChangeEndTimeToState(
      ChangeEndTime event) async* {
    yield state.copyWith(state.activity,
        timeInterval: TimeInterval(state.timeInterval.startTime, event.time));
  }

  Duration _getDuration(DateTime startTime, TimeOfDay endTime) {
    final pickedEndTimeBeforeStartTime = endTime.hour < startTime.hour ||
        endTime.hour == startTime.hour && endTime.minute < startTime.minute;

    return pickedEndTimeBeforeStartTime
        ? startTime
            .copyWith(
                day: startTime.day + 1,
                hour: endTime.hour,
                minute: endTime.minute)
            .difference(startTime)
        : Duration(
            hours: endTime.hour - startTime.hour,
            minutes: endTime.minute - startTime.minute,
          );
  }
}
