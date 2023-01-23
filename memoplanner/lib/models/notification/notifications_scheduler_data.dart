import 'package:equatable/equatable.dart';
import 'package:memoplanner/storage/all.dart';
import 'package:memoplanner/models/all.dart';

class NotificationsSchedulerData extends Equatable {
  final Iterable<Activity> activities;
  final Iterable<TimerAlarm> timers;
  final String language;
  final bool alwaysUse24HourFormat;
  final AlarmSettings settings;
  final FileStorage fileStorage;
  final DateTime? dateTime;

  const NotificationsSchedulerData({
    required this.activities,
    required this.timers,
    required this.language,
    required this.alwaysUse24HourFormat,
    required this.settings,
    required this.fileStorage,
    this.dateTime,
  });

  Map<String, dynamic> toMap() {
    final activitiesList =
        activities.map((e) => e.wrapWithDbModel().toJson()).toList();
    final timersList = timers.map((e) => e.toJson()).toList();
    return {
      'activities': activitiesList,
      'timers': timersList,
      'language': language,
      'alwaysUse24HourFormat': alwaysUse24HourFormat,
      'settings': settings.toMap(),
      'fileStorage': fileStorage.dir,
      'dateTime': dateTime?.millisecondsSinceEpoch,
    };
  }

  factory NotificationsSchedulerData.fromMap(Map<String, dynamic> data) {
    final activities = (data['activities'] as List)
        .map((e) => DbActivity.fromJson(e).activity)
        .toList();
    final timers = (data['timers'] as List)
        .map((e) => NotificationAlarm.fromJson(e) as TimerAlarm)
        .toList();
    final dateTime = data['dateTime'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['dateTime'])
        : null;
    return NotificationsSchedulerData(
      activities: activities,
      timers: timers,
      language: data['language'],
      alwaysUse24HourFormat: data['alwaysUse24HourFormat'],
      settings: AlarmSettings.fromMap(data['settings']),
      fileStorage: FileStorage(data['fileStorage']),
      dateTime: dateTime,
    );
  }

  @override
  List<Object?> get props => [
        activities,
        timers,
        language,
        settings,
        fileStorage,
        dateTime,
      ];
}
