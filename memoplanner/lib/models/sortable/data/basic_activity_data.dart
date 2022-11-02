import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

abstract class BasicActivityData extends SortableData {}

class BasicActivityDataItem extends BasicActivityData {
  final int alarmType, category, duration, startTime;
  final bool checkable, fullDay, removeAfter, secret;
  final String fileId, icon, info, reminders, activityTitle, name;
  final UnmodifiableSetView<int> secretExemptions;

  BasicActivityDataItem._({
    this.alarmType = 0,
    this.category = 0,
    this.duration = 0,
    this.startTime = 0,
    this.checkable = false,
    this.fullDay = false,
    this.removeAfter = false,
    this.secret = false,
    this.fileId = '',
    this.icon = '',
    this.info = '',
    this.reminders = '',
    this.activityTitle = '',
    this.name = '',
    Set<int> secretExemptions = const {},
  }) : secretExemptions = UnmodifiableSetView(secretExemptions);

  factory BasicActivityDataItem.fromJson(String data) {
    final sortableData = json.decode(data);
    return BasicActivityDataItem._(
      alarmType: sortableData['alarmType'] ?? 0,
      category: sortableData['category'] ?? 0,
      duration: sortableData['duration'] ?? 0,
      startTime: sortableData['startTime'] ?? 0,
      checkable: sortableData['checkable'] ?? false,
      fullDay: sortableData['fullDay'] ?? false,
      removeAfter: sortableData['removeAfter'] ?? false,
      secret: sortableData['secret'] ?? false,
      fileId: sortableData['fileId'] ?? '',
      icon: sortableData['icon'] ?? '',
      info: sortableData['info'] ?? '',
      reminders: sortableData['reminders'] ?? '',
      activityTitle: sortableData['title'] ?? '',
      name: sortableData['name'] ?? '',
      secretExemptions:
          DbActivity.exemptionsListToSet(sortableData['secretExemptions']),
    );
  }

  factory BasicActivityDataItem.createNew({
    String title = '',
    Duration startTime = Duration.zero,
    Duration duration = Duration.zero,
  }) =>
      BasicActivityDataItem._(
        activityTitle: title,
        startTime: startTime.inMilliseconds,
        duration: duration.inMilliseconds,
      );

  factory BasicActivityDataItem.fromActivity(Activity activity) =>
      BasicActivityDataItem._(
        name: activity.title,
        activityTitle: activity.title,
        startTime: Duration(
          hours: activity.startTime.hour,
          minutes: activity.startTime.minute,
        ).inMilliseconds,
        duration: activity.duration.inMilliseconds,
        alarmType: activity.alarmType,
        category: activity.category,
        checkable: activity.checkable,
        fullDay: activity.fullDay,
        removeAfter: activity.removeAfter,
        secret: activity.secret,
        fileId: activity.fileId,
        icon: activity.icon,
        info: activity.infoItem.infoItemJson(),
        reminders: activity.reminderBefore.join(';'),
        secretExemptions: activity.secretExemptions,
      );

  TimeOfDay? get startTimeOfDay =>
      startTime == 0 && duration <= 0 ? null : startTime.toTimeOfDay();
  TimeOfDay? get endTimeOfDay =>
      duration == 0 ? null : (startTime + duration).toTimeOfDay();

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;

  @override
  List<Object> get props => [
        alarmType,
        category,
        duration,
        startTime,
        checkable,
        fullDay,
        removeAfter,
        secret,
        fileId,
        icon,
        info,
        reminders,
        activityTitle,
        name,
        secretExemptions,
      ];

  @override
  String title(t) => activityTitle.isEmpty ? name : activityTitle;

  @override
  String toRaw() => json.encode({
        'alarmType': alarmType,
        'category': category,
        'duration': duration,
        'startTime': startTime,
        'checkable': checkable,
        'fullDay': fullDay,
        'removeAfter': removeAfter,
        'secret': secret,
        'fileId': fileId,
        'icon': icon,
        'info': info,
        'reminders': reminders,
        'title': activityTitle,
        'name': name,
        'secretExemptions': secretExemptions.toList(),
      });

  Activity toActivity({
    required String timezone,
    required DateTime day,
    required String calendarId,
  }) =>
      Activity(
        title: activityTitle,
        startTime: day,
        timezone: timezone,
        alarmType: alarmType,
        category: category,
        duration: Duration(milliseconds: duration),
        checkable: checkable,
        fullDay: fullDay,
        removeAfter: removeAfter,
        secret: secret,
        fileId: fileId,
        icon: icon,
        infoItemString: InfoItem.fromJsonString(info).toBase64(),
        reminderBefore: DbActivity.parseReminders(reminders),
        calendarId: calendarId,
        secretExemptions: secretExemptions,
      );

  TimeInterval toTimeInterval({required DateTime startDate}) => TimeInterval(
        startDate: startDate.onlyDays(),
        startTime: startTimeOfDay,
        endTime: endTimeOfDay,
      );
}

class BasicActivityDataFolder extends BasicActivityData {
  final String name, icon, fileId;

  BasicActivityDataFolder._({
    required this.name,
    required this.icon,
    required this.fileId,
  });

  factory BasicActivityDataFolder.fromJson(String data) {
    final sortableData = json.decode(data);
    return BasicActivityDataFolder._(
      name: sortableData['name'] ?? '',
      icon: sortableData['icon'] ?? '',
      fileId: sortableData['fileId'] ?? '',
    );
  }

  @visibleForTesting
  factory BasicActivityDataFolder.createNew({
    String? name,
    String? icon,
    String? fileId,
  }) =>
      BasicActivityDataFolder._(
        name: name ?? '',
        icon: icon ?? '',
        fileId: fileId ?? '',
      );

  @override
  String dataFileId() => fileId;

  @override
  String dataFilePath() => icon;

  @override
  bool hasImage() => fileId.isNotEmpty || icon.isNotEmpty;

  @override
  List<Object> get props => [name, icon, fileId];

  @override
  String title(t) => name;

  @override
  String toRaw() => json.encode({
        'name': name,
        'icon': icon,
        'fileId': fileId,
      });
}
