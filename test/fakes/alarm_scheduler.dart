import 'package:seagull/models/all.dart';

int alarmSchedualCalls = 0;
AlarmScheduler get noAlarmScheduler {
  alarmSchedualCalls = 0;
  return (({
    required activities,
    required timers,
    required language,
    required alwaysUse24HourFormat,
    required settings,
    required fileStorage,
    now,
  }) async =>
      alarmSchedualCalls++);
}
