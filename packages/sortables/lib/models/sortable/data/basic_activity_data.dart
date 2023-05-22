import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sortables/models/all.dart';
import 'package:utils/utils.dart';

abstract class BasicActivityData extends SortableData {}

class BasicActivityDataItem extends BasicActivityData {
  final int alarmType, category, duration, startTime;
  final bool checkable, fullDay, removeAfter, secret;
  final String fileId, icon, info, reminders, activityTitle, name;
  final UnmodifiableSetView<int> secretExemptions;

  BasicActivityDataItem({
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
    final secretExemptions = sortableData['secretExemptions'] is Iterable
        ? sortableData['secretExemptions'].whereType<int>().toSet()
        : {};

    return BasicActivityDataItem(
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
      secretExemptions: secretExemptions,
    );
  }

  factory BasicActivityDataItem.createNew({
    String title = '',
    Duration startTime = Duration.zero,
    Duration duration = Duration.zero,
  }) =>
      BasicActivityDataItem(
        activityTitle: title,
        startTime: startTime.inMilliseconds,
        duration: duration.inMilliseconds,
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
  String title() => activityTitle.isEmpty ? name : activityTitle;

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
  String title() => name;

  @override
  String toRaw() => json.encode({
        'name': name,
        'icon': icon,
        'fileId': fileId,
      });
}
