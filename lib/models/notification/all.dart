export 'alarm.dart';
export 'payload.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/storage/file_storage.dart';

typedef NotificationStreamGetter = Stream<String> Function();
typedef AlarmScheduler = Future Function(
  Iterable<Activity> allActivities,
  String language,
  bool alwaysUse24HourFormat,
  FileStorage fileStorage,
);
typedef CancelNotificationsFunction = Future Function();
