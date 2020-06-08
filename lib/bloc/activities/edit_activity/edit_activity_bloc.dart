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
        timeInterval = TimeInterval(
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
    if (event is SaveActivity && state.canSave) {
      yield* _mapSaveActivityToState(state, event);
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
    if (this.activity == activity) return;
    if (activity.fullDay) {
      activity = activity.copyWith(
        startTime: activity.startTime.onlyDays(),
        duration: 1.days() - 1.milliseconds(),
        alarmType: NO_ALARM,
        reminderBefore: [],
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
    final oldStartDate = state.activity.startTime;
    final newStartDate = event.date
        .copyWith(hour: oldStartDate.hour, minute: oldStartDate.minute)
        .onlyMinutes();
    yield state.copyWith(state.activity.copyWith(
      startTime: newStartDate,
    ));
  }

  Stream<EditActivityState> _mapChangeStartTimeToState(
      ChangeStartTime event) async* {
    final a = state.activity;
    final newStartTime = a.startTime.copyWith(
      hour: event.time.hour,
      minute: event.time.minute,
    );

    final duration = state.timeInterval.startTime == null &&
            state.timeInterval.endTime != null
        ? _getDuration(
            newStartTime, TimeOfDay.fromDateTime(state.timeInterval.endTime))
        : a.duration;

    yield state.copyWith(
        a.copyWith(
          startTime: newStartTime,
          duration: duration,
        ),
        timeInterval: TimeInterval(
            newStartTime,
            state.timeInterval.endTime != null
                ? newStartTime.add(duration)
                : null));
  }

  Stream<EditActivityState> _mapChangeEndTimeToState(
      ChangeEndTime event) async* {
    final activity = state.activity;
    final startTime = activity.startTime;
    final newEndTime = event.time;

    if (state.timeInterval.startTime == null) {
      yield state.copyWith(activity,
          timeInterval: TimeInterval(
            state.timeInterval.startTime,
            startTime.copyWith(
              hour: newEndTime.hour,
              minute: newEndTime.minute,
            ),
          ));
      return;
    }

    if (newEndTime == null) {
      yield state.copyWith(activity.copyWith(duration: Duration.zero),
          timeInterval: TimeInterval(state.timeInterval.startTime, null));
      return;
    }

    final newDuration = _getDuration(startTime, newEndTime);

    yield state.copyWith(
      activity.copyWith(duration: newDuration),
      timeInterval: TimeInterval(
          state.timeInterval.startTime,
          state.timeInterval.startTime != null
              ? state.timeInterval.startTime.add(newDuration)
              : startTime.copyWith(
                  hour: newEndTime.hour,
                  minute: newEndTime.minute,
                )),
    );
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
