import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/timezone.dart' as tz;
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

part 'edit_activity_state.dart';

class EditActivityCubit extends Cubit<EditActivityState> {
  EditActivityCubit.edit(ActivityDay activityDay)
      : super(
          StoredActivityState(
            activityDay.activity,
            activityDay.activity.fullDay
                ? TimeInterval(
                    startDate: activityDay.day,
                    endDate: activityDay.activity.isRecurring
                        ? activityDay.activity.recurs.end
                        : null,
                  )
                : TimeInterval.fromDateTime(
                    activityDay.start,
                    activityDay.activity.hasEndTime ? activityDay.end : null,
                    activityDay.activity.isRecurring
                        ? activityDay.activity.recurs.end
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
    required DefaultsAddActivitySettings defaultsSettings,
    required String calendarId,
    BasicActivityDataItem? basicActivityData,
  }) : super(
          basicActivityData == null
              ? UnstoredActivityState(
                  Activity(
                    startTime: day,
                    timezone: tz.local.name,
                    alarmType: defaultsSettings.alarm.intValue,
                    secret: defaultsSettings.availableForType ==
                        AvailableForType.onlyMe,
                    checkable: defaultsSettings.checkable,
                    removeAfter: defaultsSettings.removeAtEndOfDay,
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

  final _log = Logger((EditActivityCubit).toString());

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
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    emit(
      state.copyWith(
        state.activity,
        timeInterval: TimeInterval(
          startTime: startTime,
          endTime: endTime,
          startDate: state.timeInterval.startDate,
          endDate: state.timeInterval.endDate,
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
        state.hasEndDate &&
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

  void changeRecurrentType(RecurrentType newType) {
    final previousType = state.activity.recurs.recurrence;
    if (newType == previousType) {
      return;
    }

    if (state.storedRecurring &&
        newType == state.originalActivity.recurs.recurrence) {
      _changeRecurrence(
        state.originalActivity.recurs,
        timeInterval: state.originalTimeInterval,
      );
      return;
    }

    final newRecurs = _newRecurs(newType, state.timeInterval.startDate);

    DateTime? getEndDate() {
      if (newType == RecurrentType.yearly) {
        return Recurs.noEndDate;
      }
      if (state.storedRecurring) {
        return state.originalTimeInterval.endDate;
      }
      return state.timeInterval.endDate;
    }

    _changeRecurrence(
      newRecurs,
      timeInterval: state.timeInterval.changeEndDate(getEndDate()),
    );
  }

  void changeRecurrentEndDate(DateTime? newEndDate) {
    if (state.storedRecurring ||
        state.activity.recurs.recurrence == RecurrentType.none ||
        state.activity.recurs.recurrence == RecurrentType.yearly) {
      _log.warning('Invalid attempt at updating recurring end date');
      return;
    }

    final newTimeInterval = state.timeInterval.changeEndDate(newEndDate);
    final newRecurs = state.activity.recurs.changeEnd(
      newEndDate ?? Recurs.noEndDate,
    );
    _changeRecurrence(newRecurs, timeInterval: newTimeInterval);
  }

  void changeWeeklyRecurring(Recurs recurs) {
    if (recurs.recurrence != RecurrentType.weekly ||
        state.activity.recurs.recurrence != RecurrentType.weekly ||
        (state.storedRecurring &&
            recurs.end != state.originalActivity.recurs.end) ||
        recurs.end != state.activity.recurs.end) {
      _log.warning(
          'Invalid attempt updating ${RecurrentType.weekly.name} recurring. ${(Recurs).toString()} provided: $recurs');
      return;
    }

    _changeRecurrence(recurs, timeInterval: state.timeInterval);
  }

  void changeSelectedMonthDays(Set<int> selectedMonthDays) {
    if (state.activity.recurs.recurrence != RecurrentType.monthly) {
      return;
    }

    _changeRecurrence(
      Recurs.monthlyOnDays(
        selectedMonthDays,
        ends: state.timeInterval.endDate,
      ),
      timeInterval: state.timeInterval,
    );
  }

  void _changeRecurrence(Recurs recurs, {TimeInterval? timeInterval}) {
    emit(
      state.copyWith(
        state.activity.copyWith(recurs: recurs),
        timeInterval: timeInterval ??
            state.timeInterval.copyWith(
              endDate: DateTime.fromMillisecondsSinceEpoch(recurs.endTime),
            ),
      ),
    );
  }

  Recurs _newRecurs(
    RecurrentType type,
    DateTime startDate, {
    DateTime? endDate,
  }) {
    switch (type) {
      case RecurrentType.weekly:
        return Recurs.weeklyOnDay(startDate.weekday, ends: endDate);
      case RecurrentType.monthly:
        return Recurs.monthly(startDate.day, ends: endDate);
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
