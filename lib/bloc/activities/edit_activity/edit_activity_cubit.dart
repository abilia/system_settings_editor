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
  EditActivityCubit.edit(ActivityDay activityDay)
      : super(
          StoredActivityState(
            activityDay.activity,
            activityDay.activity.fullDay
                ? TimeInterval(startDate: activityDay.day)
                : TimeInterval.fromDateTime(
                    activityDay.activity.startClock(activityDay.day),
                    activityDay.activity.hasEndTime
                        ? activityDay.activity.endClock(activityDay.day)
                        : null,
                    !activityDay.activity.recurs.once
                        ? DateTime.fromMillisecondsSinceEpoch(
                            activityDay.activity.recurs.endTime)
                        : null,
                  ),
            activityDay.day,
          ),
        );

  EditActivityCubit.editTemplate(
    BasicActivityDataItem basicActivityData,
    DateTime day,
  ) : super(
          StoredActivityState(
            basicActivityData.toActivity(
              timezone: tz.local.name,
              day: day,
              calendarId: '',
            ),
            TimeInterval(
              startDate: day,
              startTime: basicActivityData.startTimeOfDay,
              endTime: basicActivityData.endTimeOfDay,
            ),
            day,
          ),
        );

  EditActivityCubit.newActivity({
    required DateTime day,
    required int defaultAlarmTypeSetting,
    required String calendarId,
    BasicActivityDataItem? basicActivityData,
  }) : super(
          basicActivityData == null
              ? UnstoredActivityState(
                  Activity(
                    startTime: day,
                    timezone: tz.local.name,
                    alarmType: defaultAlarmTypeSetting,
                    calendarId: calendarId,
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
    final DateTime? endDate,
  }) {
    var timeInterval = state.timeInterval
        .copyWith(startTime: startTime, endTime: endTime ?? startTime);
    emit(
      state.copyWith(
        state.activity,
        timeInterval: endDate != null
            ? timeInterval.changeEndDate(endDate)
            : timeInterval,
      ),
    );
  }

  void changeEndDate(DateTime endDate) {
    emit(
      state.copyWith(
        state.activity.copyWith(
          recurs: state.activity.recurs.changeEnd(endDate),
        ),
        timeInterval: state.timeInterval.changeEndDate(endDate),
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

  void changeStartDate(DateTime date) {
    final newTimeInterval = state.timeInterval.copyWith(startDate: date);
    if (state.activity.recurs.yearly) {
      emit(
        state.copyWith(
          state.activity.copyWith(recurs: Recurs.yearly(date)),
          timeInterval: newTimeInterval,
        ),
      );
    } else if (state.activity.isRecurring &&
        !state.hasEndDate &&
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

  void newRecurrence({
    RecurrentType? newType,
    DateTime? startDate,
    DateTime? newEndDate,
  }) {
    if (state.storedRecurring &&
        newType == state.originalActivity.recurs.recurrance) {
      changeRecurrence(state.originalActivity.recurs);
      return;
    }
    final type = newType ?? state.activity.recurs.recurrance;
    final endDate = newEndDate ??
        (state.activity.isRecurring ? state.timeInterval.endDate : null);
    emit(
      state.copyWith(
        state.activity.copyWith(
          recurs: _newRecurs(
            type,
            startDate ?? state.timeInterval.startDate,
            endDate,
          ),
        ),
        timeInterval: state.timeInterval.changeEndDate(
          newType == RecurrentType.yearly ? Recurs.noEndDate : endDate,
        ),
      ),
    );
  }

  void changeRecurrence(Recurs recurs) {
    emit(
      state.copyWith(
        state.activity.copyWith(recurs: recurs),
        timeInterval: state.timeInterval.copyWith(
          endDate: DateTime.fromMillisecondsSinceEpoch(recurs.endTime),
        ),
      ),
    );
  }

  Recurs _newRecurs(RecurrentType type, DateTime startDate, DateTime? endDate) {
    final endOfDay = endDate?.nextDay().onlyDays().millisecondBefore();
    switch (type) {
      case RecurrentType.weekly:
        return Recurs.weeklyOnDay(endOfDay?.weekday ?? startDate.weekday,
            ends: endOfDay);
      case RecurrentType.monthly:
        return Recurs.monthly(endOfDay?.day ?? startDate.day, ends: endOfDay);
      case RecurrentType.yearly:
        return Recurs.yearly(startDate);
      default:
        return Recurs.not;
    }
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

  void setAvailableFor(AvailableForType availableFor) {
    final activity = state.activity;
    replaceActivity(
      activity.copyWith(
        secret: availableFor != AvailableForType.allSupportPersons,
        secretExemptions: const {},
      ),
    );
  }

  void toggleSupportPerson(int id) {
    final activity = state.activity;
    final supportPersons = Set<int>.from(activity.secretExemptions);
    if (!supportPersons.remove(id)) {
      supportPersons.add(id);
    }
    replaceActivity(
      activity.copyWith(secretExemptions: supportPersons),
    );
  }
}
