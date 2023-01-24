import 'package:memoplanner/models/all.dart';

int scheduleNotificationsCalls = 0;
NotificationsScheduler get noAlarmScheduler {
  scheduleNotificationsCalls = 0;
  return ((schedulerData) async => scheduleNotificationsCalls++);
}
