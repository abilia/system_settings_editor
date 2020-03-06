import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'add_activity_event.dart';
part 'add_activity_state.dart';

class AddActivityBloc extends Bloc<AddActivityEvent, AddActivityState> {
  final Activity activity;
  final ActivitiesBloc activitiesBloc;
  final bool newActivity;

  AddActivityBloc({
    @required this.activitiesBloc,
    @required this.activity,
    this.newActivity = true,
  });
  @override
  UnsavedActivityState get initialState => UnsavedActivityState(activity);

  @override
  Stream<AddActivityState> mapEventToState(
    AddActivityEvent event,
  ) async* {
    if (event is ChangeActivity) {
      yield UnsavedActivityState(event.activity);
    }
    if (event is ChangeDate) {
      yield* _mapChangeDateToState(event);
    }
    if (event is ChangeStartTime) {
      yield* _mapChangeStartTimeToState(event);
    }
    if (event is ChangeEndTime && event.time != null) {
      yield* _mapChangeEndTimeToState(event);
    }
    if (event is AddOrRemoveReminder) {
      yield* _mapAddOrRemoveReminderToState(event.reminder.inMilliseconds);
    }
    if (event is SaveActivity && state.canSave) {
      yield* _mapSaveActivityToState(state.activity);
    }
    if (event is ImageSelected) {
      yield UnsavedActivityState(
          state.activity.copyWith(fileId: event.imageId));
    }
  }

  Stream<UnsavedActivityState> _mapAddOrRemoveReminderToState(
    int reminder,
  ) async* {
    final reminders = state.activity.reminderBefore.toSet();
    if (!reminders.add(reminder)) {
      reminders.remove(reminder);
    }
    yield UnsavedActivityState(
      state.activity.copyWith(reminderBefore: reminders),
    );
  }

  Stream<SavedActivityState> _mapSaveActivityToState(Activity activity) async* {
    if (activity.fullDay) {
      final startOfDay = activity.startDateTime.onlyDays();
      final endTime = startOfDay
          .add(25.hours())
          .onlyDays()
          .subtract(1.milliseconds())
          .millisecondsSinceEpoch;
      final starTime = startOfDay.millisecondsSinceEpoch;
      activity = activity.copyWith(
        startTime: starTime,
        endTime: endTime,
        duration: endTime - starTime,
        alarmType: NO_ALARM,
        reminderBefore: [],
      );
    }

    activitiesBloc
        .add(newActivity ? AddActivity(activity) : UpdateActivity(activity));
    yield SavedActivityState(activity);
  }

  Stream<UnsavedActivityState> _mapChangeDateToState(ChangeDate event) async* {
    final oldStartDate = state.activity.startDateTime;
    final newStartDate = event.date
        .onlyDays()
        .add(Duration(hours: oldStartDate.hour, minutes: oldStartDate.minute));
    yield UnsavedActivityState(
      state.activity.copyWith(
        startTime: newStartDate.millisecondsSinceEpoch,
        endTime: newStartDate.millisecondsSinceEpoch,
      ),
    );
  }

  Stream<UnsavedActivityState> _mapChangeStartTimeToState(
      ChangeStartTime event) async* {
    final a = state.activity;
    final newStartTime = a.start
        .onlyDays()
        .add(
          Duration(
            hours: event.time.hour,
            minutes: event.time.minute,
          ),
        )
        .millisecondsSinceEpoch;
    yield UnsavedActivityState(
      a.copyWith(
        startTime: newStartTime,
        endTime: newStartTime,
      ),
    );
  }

  Stream<UnsavedActivityState> _mapChangeEndTimeToState(
      ChangeEndTime event) async* {
    final activity = state.activity;
    final startTime = activity.start;
    final newEndTime = event.time;

    final pickedEndTimeBeforeStartTime = newEndTime.hour < startTime.hour ||
        newEndTime.hour == startTime.hour &&
            newEndTime.minute < startTime.minute;

    final newDuration = pickedEndTimeBeforeStartTime
        ? startTime
            .copyWith(
                day: startTime.day + 1,
                hour: newEndTime.hour,
                minute: newEndTime.minute)
            .difference(startTime)
        : Duration(
            hours: event.time.hour - startTime.hour,
            minutes: event.time.minute - startTime.minute,
          );

    yield UnsavedActivityState(
      activity.copyWith(duration: newDuration.inMilliseconds),
    );
  }
}
