import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:file_storage/file_storage.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class NotificationsSchedulerData extends Equatable {
  final List<NotificationAlarm> notifications;
  final String language;
  final bool alwaysUse24HourFormat;
  final AlarmSettings settings;
  final FileStorage fileStorage;
  final DateTime? dateTime;
  final int maxNotifications;

  const NotificationsSchedulerData._({
    required this.notifications,
    required this.language,
    required this.alwaysUse24HourFormat,
    required this.settings,
    required this.fileStorage,
    required this.maxNotifications,
    this.dateTime,
  });

  factory NotificationsSchedulerData.fromCalendarEvents({
    required Iterable<Activity> activities,
    required Iterable<AbiliaTimer> timers,
    required String language,
    required bool alwaysUse24HourFormat,
    required AlarmSettings settings,
    required FileStorage fileStorage,
    int maxNotifications =
        64, // https://pub.dev/packages/flutter_local_notifications#ios-pending-notifications-limit
    DateTime? dateTime,
  }) {
    final now = dateTime != null ? () => dateTime : DateTime.now;
    final from = settings.disabledUntilDate.isAfter(now())
        ? settings.disabledUntilDate
        : now().nextMinute();
    final activityNotifications = activities.alarmsFrom(
      from,
      take: max(maxNotifications - timers.length, 0),
    );
    final notifications = [...activityNotifications, ...timers.toAlarm()];

    return NotificationsSchedulerData._(
      notifications: notifications,
      language: language,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
      settings: settings,
      fileStorage: fileStorage,
      maxNotifications: maxNotifications,
      dateTime: dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    final notificationsMap = {
      for (int i = 0; i < notifications.length; i++)
        i: notifications.elementAt(i).toJson()
    };
    return {
      'notifications': notificationsMap,
      'language': language,
      'alwaysUse24HourFormat': alwaysUse24HourFormat,
      'settings': settings.toMap(),
      'fileStorage': fileStorage.dir,
      'dateTime': dateTime?.millisecondsSinceEpoch,
      'maxNotifications': maxNotifications,
    };
  }

  factory NotificationsSchedulerData.fromMap(Map<String, dynamic> data) {
    final notifications = (data['notifications'] as Map)
        .values
        .map((e) => NotificationAlarm.fromJson(e))
        .toList();
    final dateTime = data['dateTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['dateTime'])
        : null;
    return NotificationsSchedulerData._(
      notifications: notifications,
      language: data['language'],
      alwaysUse24HourFormat: data['alwaysUse24HourFormat'],
      settings: AlarmSettings.fromMap(data['settings']),
      fileStorage: FileStorage(data['fileStorage']),
      maxNotifications: data['maxNotifications'],
      dateTime: dateTime,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        language,
        settings,
        fileStorage,
        dateTime,
        maxNotifications,
      ];
}
