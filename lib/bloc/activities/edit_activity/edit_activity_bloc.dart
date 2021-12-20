import 'dart:async';
import 'dart:collection';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/timezone.dart' as tz;
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
        ) {
    on<EditActivityEvent>(_mapEventToState, transformer: sequential());
  }

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
        ) {
    on<EditActivityEvent>(_mapEventToState, transformer: sequential());
  }

  Future _mapEventToState(
    EditActivityEvent event,
    Emitter<EditActivityState> emit,
  ) async {
    if (event is ReplaceActivity) {
      await _replaceActivity(event, emit);
    }
    if (event is ChangeDate) {
      await _mapChangeDateToState(event, emit);
    }
    if (event is AddOrRemoveReminder) {
      await _mapAddOrRemoveReminderToState(event.reminder.inMilliseconds, emit);
    }
    if (event is ActivitySavedSuccessfully) {
      await _activitySaved(event, emit);
    }
    if (event is ChangeTimeInterval) {
      await _changeTimeInterval(event, emit);
    }
    if (event is ImageSelected) {
      await _imageSelected(event, emit);
    }
    if (event is ChangeInfoItemType) {
      await _mapChangeInfoItemTypeToState(event, emit);
    }
    if (event is AddBasiActivity) {
      await _mapAddBasicActivityToState(event, emit);
    }
  }

  Future _replaceActivity(
      ReplaceActivity event, Emitter<EditActivityState> emit) async {
    emit(state.copyWith(event.activity));
  }

  Future _activitySaved(
      ActivitySavedSuccessfully event, Emitter<EditActivityState> emit) async {
    final state = this.state;
    emit(StoredActivityState(
      event.activitySaved,
      state.timeInterval,
      state is StoredActivityState
          ? state.day
          : event.activitySaved.startTime.onlyDays(),
    ));
  }

  Future _changeTimeInterval(
      ChangeTimeInterval event, Emitter<EditActivityState> emit) async {
    emit(state.copyWith(
      state.activity,
      timeInterval: state.timeInterval.copyWith(
        startTime: event.startTime,
        endTime: event.endTime ?? event.startTime,
      ),
    ));
  }

  Future _imageSelected(
      ImageSelected event, Emitter<EditActivityState> emit) async {
    emit(state.copyWith(
      state.activity.copyWith(
        fileId: event.imageId,
        icon: event.path,
      ),
    ));
  }

  Future _mapAddOrRemoveReminderToState(
      int reminder, Emitter<EditActivityState> emit) async {
    final reminders = state.activity.reminderBefore.toSet();
    if (!reminders.add(reminder)) {
      reminders.remove(reminder);
    }
    emit(state.copyWith(state.activity.copyWith(reminderBefore: reminders)));
  }

  Future _mapChangeDateToState(
      ChangeDate event, Emitter<EditActivityState> emit) async {
    final newTimeInterval = state.timeInterval.copyWith(startDate: event.date);
    if (state.activity.recurs.yearly) {
      emit(state.copyWith(
        state.activity.copyWith(recurs: Recurs.yearly(event.date)),
        timeInterval: newTimeInterval,
      ));
    } else if (state.activity.isRecurring &&
        state.activity.recurs.end.isDayBefore(event.date)) {
      emit(state.copyWith(
        state.activity.copyWith(
          recurs: state.activity.recurs.changeEnd(event.date),
        ),
        timeInterval: newTimeInterval,
      ));
    } else {
      emit(state.copyWith(
        state.activity,
        timeInterval: newTimeInterval,
      ));
    }
  }

  Future _mapChangeInfoItemTypeToState(
      ChangeInfoItemType event, Emitter<EditActivityState> emit) async {
    final oldInfoItem = state.activity.infoItem;
    final oldInfoItemType = oldInfoItem.runtimeType;
    final newInfoType = event.infoItemType;
    if (newInfoType == oldInfoItemType) return;
    final infoItems = Map.fromEntries(state.infoItems.entries);
    infoItems[oldInfoItemType] = oldInfoItem;

    emit(state.copyWith(
      state.activity.copyWith(
        infoItem: infoItems[newInfoType] ?? _newInfoItem(newInfoType),
      ),
      infoItems: infoItems,
    ));
  }

  Future _mapAddBasicActivityToState(
      AddBasiActivity event, Emitter<EditActivityState> emit) async {
    emit(UnstoredActivityState(
      event.basicActivityData.toActivity(timezone: tz.local.name, day: day),
      event.basicActivityData.toTimeInterval(startDate: day),
    ));
  }

  InfoItem _newInfoItem(Type infoItemType) {
    switch (infoItemType) {
      case NoteInfoItem:
        return const NoteInfoItem();
      case Checklist:
        return Checklist();
      default:
        return InfoItem.none;
    }
  }
}
