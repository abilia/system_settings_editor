import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'edit_activity_event.dart';
part 'edit_activity_state.dart';

class EditActivityBloc extends Bloc<EditActivityEvent, EditActivityState> {
  final Activity activity;
  final ActivitiesBloc activitiesBloc;
  final DateTime day;

  EditActivityBloc({
    @required this.activitiesBloc,
    this.day,
    Activity activity,
    DateTime now,
  })  : assert(
            activity == null && now != null || activity != null && day != null),
        activity = activity == null
            ? Activity.createNew(
                title: '',
                startTime: now.nextHalfHour(),
                timezone: now.timeZoneName,
              )
            : activity.isRecurring
                ? activity.copyWith(startTime: activity.startClock(day))
                : activity;
  @override
  EditActivityState get initialState => day == null
      ? UnstoredActivityState(activity)
      : StoredActivityState(activity, day);

  @override
  Stream<EditActivityState> mapEventToState(
    EditActivityEvent event,
  ) async* {
    if (event is ChangeActivity) {
      yield state.copyWith(event.activity);
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
      yield* _mapSaveActivityToState(state, event);
    }
    if (event is ImageSelected) {
      yield state.copyWith(
          state.activity.copyWith(fileId: event.imageId), event.newImage);
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
        startTime: activity.start.onlyDays(),
        duration: 1.days() - 1.milliseconds(),
        alarmType: NO_ALARM,
        reminderBefore: [],
      );
    }

    if (state is UnstoredActivityState) {
      activitiesBloc.add(AddActivity(activity));
    } else if (event is SaveRecurringActivity) {
      activitiesBloc
          .add(UpdateRecurringActivity(activity, event.applyTo, event.day));
    } else {
      activitiesBloc.add(UpdateActivity(activity));
    }
    yield StoredActivityState(activity,
        state is StoredActivityState ? state.day : activity.start.onlyDays());
  }

  Stream<EditActivityState> _mapChangeDateToState(ChangeDate event) async* {
    final oldStartDate = state.activity.start;
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
    final newStartTime = a.start.copyWith(
      hour: event.time.hour,
      minute: event.time.minute,
    );
    yield state.copyWith(a.copyWith(
      startTime: newStartTime,
    ));
  }

  Stream<EditActivityState> _mapChangeEndTimeToState(
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

    yield state.copyWith(
      activity.copyWith(duration: newDuration),
      state.newImage,
    );
  }
}
