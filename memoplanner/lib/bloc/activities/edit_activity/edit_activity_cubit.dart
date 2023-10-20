import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_logging/logging_levels_mixin.dart';
import 'package:utils/timezone.dart' as tz;

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
            activityDay.activity.recurs.weekly &&
                    activityDay.activity.recurs.data == Recurs.allDaysOfWeek
                ? RecurrentType.daily
                : activityDay.activity.recurs.recurrence,
          ),
        );

  EditActivityCubit.editTemplate(
    BasicActivityDataItem basicActivityData,
    DateTime day,
  ) : super(
          StoredActivityState(
            Activity.fromBaseActivity(
              baseActivity: basicActivityData,
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
            RecurrentType.none,
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
                  RecurrentType.none,
                )
              : UnstoredActivityState(
                  Activity.fromBaseActivity(
                      baseActivity: basicActivityData,
                      timezone: tz.local.name,
                      day: day,
                      calendarId: calendarId),
                  TimeInterval(
                      startDate: day.onlyDays(),
                      startTime: basicActivityData.startTimeOfDay,
                      endTime: basicActivityData.endTimeOfDay),
                  RecurrentType.none,
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
        state.selectedRecurrentType,
      ),
    );
  }

  void changeTimeInterval({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) =>
      _changeTimeInterval(
        TimeInterval(
          startTime: startTime,
          endTime: endTime,
          startDate: state.timeInterval.startDate,
          endDate: state.timeInterval.endDate,
        ),
      );

  void _changeTimeInterval(TimeInterval timeInterval, [Activity? activity]) =>
      emit(
        state.copyWith(activity ?? state.activity, timeInterval: timeInterval),
      );

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
      return _changeTimeInterval(
        newTimeInterval,
        state.activity.copyWith(
          recurs: Recurs.yearly(date),
        ),
      );
    }
    final isDateBeforeRecurringEndTime = state.activity.isRecurring &&
        state.hasEndDate &&
        state.activity.recurs.end.isDayBefore(date);
    if (isDateBeforeRecurringEndTime) {
      return emit(
        state.copyWith(
          state.activity
              .copyWith(recurs: state.activity.recurs.changeEnd(date)),
          timeInterval: newTimeInterval.copyWithEndDate(date),
        ),
      );
    }
    _changeTimeInterval(newTimeInterval);
  }

  void setInfoItem(InfoItem infoItem) {
    emit(
      state.copyWith(
        state.activity.copyWith(infoItem: infoItem),
      ),
    );
  }

  void removeInfoItem() {
    emit(
      state.copyWith(
        state.activity.copyWith(infoItem: const NoInfoItem()),
      ),
    );
  }

  void createNewInfoItem(Type newInfoType) {
    emit(
      state.copyWith(
        state.activity.copyWith(infoItem: _newInfoItem(newInfoType)),
      ),
    );
  }

  InfoItem _newInfoItem(Type infoItemType) {
    switch (infoItemType) {
      case const (NoteInfoItem):
        return const NoteInfoItem();
      case const (Checklist):
        return Checklist();
      case const (VideoInfoItem):
        return const VideoInfoItem();
      default:
        return InfoItem.none;
    }
  }

  void changeRecurrentType(RecurrentType newType) {
    if (newType == state.selectedRecurrentType) {
      return;
    }

    if (state.storedRecurring &&
        newType == state.originalActivity.recurs.recurrence) {
      return _changeRecurrence(
        state.originalActivity.recurs,
        timeInterval: state.originalTimeInterval,
        selectedRecurrentType: newType,
      );
    }

    final newRecurs = _newRecurs(newType, state.timeInterval.startDate);

    DateTime? getEndDate() {
      if (newType == RecurrentType.yearly) {
        return noEndDate;
      }
      if (state.storedRecurring) {
        return state.originalTimeInterval.endDate;
      }
      return state.timeInterval.endDate;
    }

    _changeRecurrence(
      newRecurs,
      timeInterval: state.timeInterval.copyWithEndDate(getEndDate()),
      selectedRecurrentType: newType,
    );
  }

  void changeRecurrentEndDate(DateTime? newEndDate) {
    if (state.storedRecurring ||
        !state.activity.recurs.isRecurring ||
        state.activity.recurs.yearly) {
      _log.warning('Invalid attempt at updating recurring end date');
      return;
    }

    final newTimeInterval = state.timeInterval.copyWithEndDate(newEndDate);
    final newRecurs = state.activity.recurs.changeEnd(
      newEndDate ?? noEndDate,
    );
    _changeRecurrence(
      newRecurs,
      timeInterval: newTimeInterval,
      selectedRecurrentType: state.selectedRecurrentType,
    );
  }

  void changeWeeklyRecurring(Recurs recurs) {
    if (!recurs.weekly ||
        !state.activity.recurs.weekly ||
        (state.storedRecurring &&
            recurs.end != state.originalActivity.recurs.end) ||
        recurs.end != state.activity.recurs.end) {
      _log.warning(
          'Invalid attempt updating ${RecurrentType.weekly.name} recurring. ${(Recurs).toString()} provided: $recurs');
      return;
    }

    _changeRecurrence(
      recurs,
      timeInterval: state.timeInterval,
      selectedRecurrentType: RecurrentType.weekly,
    );
  }

  void changeSelectedMonthDays(Set<int> selectedMonthDays) {
    if (!state.activity.recurs.monthly) {
      return;
    }

    _changeRecurrence(
      Recurs.monthlyOnDays(
        selectedMonthDays,
        ends: state.timeInterval.endDate,
      ),
      selectedRecurrentType: RecurrentType.monthly,
      timeInterval: state.timeInterval,
    );
  }

  void _changeRecurrence(
    Recurs recurs, {
    required RecurrentType selectedRecurrentType,
    TimeInterval? timeInterval,
  }) {
    emit(
      state.copyWith(
        state.activity.copyWith(recurs: recurs),
        timeInterval: timeInterval ??
            state.timeInterval.copyWithEndDate(
              DateTime.fromMillisecondsSinceEpoch(recurs.endTime),
            ),
        selectedRecurrentType: selectedRecurrentType,
      ),
    );
  }

  Recurs _newRecurs(
    RecurrentType type,
    DateTime startDate, {
    DateTime? endDate,
  }) {
    switch (type) {
      case RecurrentType.daily:
        return Recurs.everyDay;
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
