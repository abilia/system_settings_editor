export 'notification_alarm.dart';
export 'converter.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';

typedef AlarmScheduler = Future Function({
  required Iterable<Activity> activities,
  required Iterable<TimerAlarm> timers,
  required String language,
  required bool alwaysUse24HourFormat,
  required AlarmSettings settings,
  required FileStorage fileStorage,
  DateTime Function()? now,
});
