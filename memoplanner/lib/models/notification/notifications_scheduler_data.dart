import 'package:equatable/equatable.dart';
import 'package:file_storage/file_storage.dart';
import 'package:memoplanner/models/all.dart';

class NotificationsSchedulerData extends Equatable {
  final Iterable<Activity> activities;
  final Iterable<TimerAlarm> timers;
  final String language;
  final bool alwaysUse24HourFormat;
  final AlarmSettings settings;
  final FileStorage fileStorage;

  const NotificationsSchedulerData({
    required this.activities,
    required this.timers,
    required this.language,
    required this.alwaysUse24HourFormat,
    required this.settings,
    required this.fileStorage,
  });

  Map<String, dynamic> toMap() {
    final activitiesMap = {
      for (int i = 0; i < activities.length; i++)
        i: activities.elementAt(i).wrapWithDbModel().toJson()
    };
    final timersMap = {
      for (int i = 0; i < timers.length; i++) i: timers.elementAt(i).toJson()
    };
    return {
      'activities': activitiesMap,
      'timers': timersMap,
      'language': language,
      'alwaysUse24HourFormat': alwaysUse24HourFormat,
      'settings': settings.toMap(),
      'fileStorage': fileStorage.dir,
    };
  }

  factory NotificationsSchedulerData.fromMap(Map<String, dynamic> data) {
    final activities = (data['activities'] as Map)
        .values
        .map((e) => DbActivity.fromJson(e).activity)
        .toList();
    final timers = (data['timers'] as Map)
        .values
        .map((e) => NotificationAlarm.fromJson(e) as TimerAlarm)
        .toList();
    return NotificationsSchedulerData(
      activities: activities,
      timers: timers,
      language: data['language'],
      alwaysUse24HourFormat: data['alwaysUse24HourFormat'],
      settings: AlarmSettings.fromMap(data['settings']),
      fileStorage: FileStorage(data['fileStorage']),
    );
  }

  @override
  List<Object?> get props => [
        activities,
        timers,
        language,
        settings,
        fileStorage,
      ];
}
