export 'alarm.dart';
export 'payload.dart';

import 'package:seagull/models.dart';

typedef Stream<String> NotificationStreamGetter();
typedef Future AlarmSchedualer(Iterable<Activity> allActivities,
    {Duration forDuration});
typedef Future CancelNotificationsFunction();
