import 'dart:async';

import 'package:logging/logging.dart';
import 'package:memoplanner/models/all.dart';

export 'converter.dart';
export 'notification_alarm.dart';
export 'notifications_scheduler_data.dart';

typedef Logging = void Function(Level logLevel, Object? message,
    [Object? error, StackTrace? stackTrace, Zone? zone]);

typedef NotificationsScheduler = Future Function(
    NotificationsSchedulerData schedulerData);
