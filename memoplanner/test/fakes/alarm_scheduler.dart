import 'package:memoplanner/models/all.dart';

int alarmScheduleCalls = 0;
AlarmScheduler get noAlarmScheduler {
  alarmScheduleCalls = 0;
  return (({
    required activities,
    required timers,
    required language,
    required alwaysUse24HourFormat,
    required settings,
    required fileStorage,
    now,
  }) async =>
      alarmScheduleCalls++);
}
