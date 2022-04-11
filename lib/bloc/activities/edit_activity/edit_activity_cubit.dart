import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/timezone.dart' as tz;
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

part 'edit_activity_state.dart';

class EditActivityCubit extends Cubit<EditActivityState> {
  final DateTime day;

  EditActivityCubit.edit(ActivityDay activityDay)
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

  EditActivityCubit.newActivity({
    required this.day,
    required int defaultAlarmTypeSetting,
    required String calendarId,
    BasicActivityDataItem? basicActivityData,
  }) : super(
          basicActivityData == null
              ? UnstoredActivityState(
                  Activity.createNew(
                    title: '',
                    calendarId: calendarId,
                    startTime: day,
                    timezone: tz.local.name,
                    alarmType: defaultAlarmTypeSetting,
                  ),
                  TimeInterval(startDate: day),
                )
              : UnstoredActivityState(
                  basicActivityData.toActivity(
                    timezone: tz.local.name,
                    day: day,
                    calendarId: calendarId,
                  ),
                  basicActivityData.toTimeInterval(startDate: day),
                ),
        );

  void replaceActivity(Activity activity) => emit(state.copyWith(activity));

  void activitySaved(Activity activitySaved) {
    final state = this.state;
    emit(
      StoredActivityState(
        activitySaved,
        state.timeInterval,
        state is StoredActivityState
            ? state.day
            : activitySaved.startTime.onlyDays(),
      ),
    );
  }

  void changeTimeInterval({
    final TimeOfDay? startTime,
    final TimeOfDay? endTime,
  }) {
    emit(
      state.copyWith(
        state.activity,
        timeInterval: state.timeInterval.copyWith(
          startTime: startTime,
          endTime: endTime ?? startTime,
        ),
      ),
    );
  }

  void imageSelected(AbiliaFile event) {
    emit(
      state.copyWith(
        state.activity.copyWith(
          fileId: event.id,
          icon: event.path,
        ),
      ),
    );
  }

  void addOrRemoveReminder(Duration reminderDuration) {
    final reminder = reminderDuration.inMilliseconds;

    final reminders = state.activity.reminderBefore.toSet();
    if (!reminders.add(reminder)) {
      reminders.remove(reminder);
    }
    emit(state.copyWith(state.activity.copyWith(reminderBefore: reminders)));
  }

  void changeDate(DateTime date) {
    final newTimeInterval = state.timeInterval.copyWith(startDate: date);
    if (state.activity.recurs.yearly) {
      emit(
        state.copyWith(
          state.activity.copyWith(recurs: Recurs.yearly(date)),
          timeInterval: newTimeInterval,
        ),
      );
    } else if (state.activity.isRecurring &&
        state.activity.recurs.end.isDayBefore(date)) {
      emit(
        state.copyWith(
          state.activity.copyWith(
            recurs: state.activity.recurs.changeEnd(date),
          ),
          timeInterval: newTimeInterval,
        ),
      );
    } else {
      emit(
        state.copyWith(
          state.activity,
          timeInterval: newTimeInterval,
        ),
      );
    }
  }

  void changeInfoItemType(Type newInfoType) {
    final oldInfoItem = state.activity.infoItem;
    final oldInfoItemType = oldInfoItem.runtimeType;
    if (newInfoType == oldInfoItemType) return;
    final infoItems = Map.fromEntries(state.infoItems.entries);
    infoItems[oldInfoItemType] = oldInfoItem;

    emit(
      state.copyWith(
        state.activity.copyWith(
          infoItem: infoItems[newInfoType] ?? _newInfoItem(newInfoType),
        ),
        infoItems: infoItems,
      ),
    );
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
