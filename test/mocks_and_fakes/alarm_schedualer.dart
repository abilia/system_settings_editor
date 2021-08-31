import 'package:seagull/models/all.dart';

int alarmSchedualCalls = 0;
AlarmScheduler get noAlarmScheduler {
  alarmSchedualCalls = 0;
  return ((a, b, c, d, e, {now}) async => alarmSchedualCalls++);
}
