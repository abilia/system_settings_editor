import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import 'package:seagull/repository/timezone.dart' as tz;

part 'edit_activity_event.dart';
part 'edit_activity_state.dart';

class EditActivityBloc extends Bloc<EditActivityEvent, EditActivityState> {
  final DateTime day;

  EditActivityBloc.edit(ActivityDay activityDay)
      : day = activityDay.day,
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
    required this.day,
    required int defaultAlarmTypeSetting,
  }) : super(
          UnstoredActivityState(
            Activity.createNew(
              title: '',
              startTime: day,
              timezone: tz.local.name,
              alarmType: defaultAlarmTypeSetting,
            ),
            TimeInterval(startDate: day),
          ),
        );

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
    if (event is ActivitySavedSuccessfully) {
      final state = this.state;
      yield StoredActivityState(
        event.activitySaved,
        state.timeInterval,
        state is StoredActivityState
            ? state.day
            : event.activitySaved.startTime.onlyDays(),
      );
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
    if (event is AddBasiActivity) {
      yield* _mapAddBasicActivityToState(event);
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

  Stream<EditActivityState> _mapAddBasicActivityToState(
      AddBasiActivity event) async* {
    yield UnstoredActivityState(
      event.basicActivityData.toActivity(timezone: tz.local.name, day: day),
      event.basicActivityData.toTimeInterval(startDate: day),
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
