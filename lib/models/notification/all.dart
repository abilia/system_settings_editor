export 'alarm.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';

typedef AlarmScheduler = Future Function(
  Iterable<Activity> allActivities,
  String language,
  bool alwaysUse24HourFormat,
  AlarmSettings settings,
  FileStorage fileStorage, {
  DateTime Function()? now,
});
