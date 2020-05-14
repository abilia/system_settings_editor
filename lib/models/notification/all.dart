export 'alarm.dart';
export 'payload.dart';

import 'package:seagull/models/all.dart';

typedef NotificationStreamGetter = Stream<String> Function();
typedef AlarmScheduler = Future Function(
  Iterable<Activity> allActivities,
  String language,
  bool alwaysUse24HourFormat,
);
typedef CancelNotificationsFunction = Future Function();
