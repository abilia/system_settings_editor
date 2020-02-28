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

  AddActivityBloc({@required this.activitiesBloc, @required this.activity});
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
    if (event is SaveActivity && state.canSave) {
      activitiesBloc.add(AddActivity(state.activity));
      yield SavedActivityState(state.activity);
    }
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
    final a = state.activity;
    final startTime = a.start;
    final newEndTime = event.time;
    if (TimeOfDay.fromDateTime(startTime) == newEndTime) return;

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
      a.copyWith(duration: newDuration.inMilliseconds),
    );
  }
}
