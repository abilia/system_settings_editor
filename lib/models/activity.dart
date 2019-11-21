import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:seagull/models.dart';
import 'package:uuid/uuid.dart';

class Activity extends Equatable {
  AlarmType get alarm => AlarmType.fromInt(alarmType);
  DateTime endClock(DateTime day) => startClock(day).add(Duration(milliseconds:  duration));
  DateTime startClock(DateTime day) => recurrentType == 0 ? startDateTime : DateTime(day.year, day.month, day.day, startDateTime.hour, startDateTime.minute);
  DateTime get start => DateTime.fromMillisecondsSinceEpoch(startTime);
  DateTime get end => DateTime.fromMillisecondsSinceEpoch(startTime + duration);
  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(startTime);
  DateTime get endDateTime => DateTime.fromMillisecondsSinceEpoch(endTime);
  RecurrentType get recurrance => RecurrentType.values[recurrentType];
  final String id, seriesId, title, fileId, icon, infoItem;
  final int startTime, endTime, duration, category, revision, alarmType, recurrentType, recurrentData;
  final bool deleted, fullDay;
  final UnmodifiableListView<int> reminderBefore;
  const Activity._({
    @required this.id,
    @required this.seriesId,
    @required this.title,
    @required this.startTime,
    @required this.endTime,
    @required this.duration,
    @required this.category,
    @required this.deleted,
    @required this.revision,
    @required this.alarmType,
    @required this.fullDay,
    @required this.recurrentType,
    @required this.recurrentData,
    this.reminderBefore,
    this.infoItem,
    this.icon,
    this.fileId,
  })  : assert(title != null || fileId != null),
        assert(id != null),
        assert(seriesId != null),
        assert(revision != null),
        assert(alarmType != null),
        assert(recurrentType >= 0 && recurrentType < 4),
        assert(startTime > 0),
        assert(endTime >= startTime);

  factory Activity.createNew({
    @required String title,
    @required int startTime,
    @required int duration,
    @required int category,
    @required Iterable<int> reminderBefore,
    int endTime,
    int recurrentType,
    int recurrentData,
    bool fullDay = false,
    int alarmType = ALARM_SOUND_AND_VIBRATION_ONLY_ON_START,
    String infoItem,
    String fileId,
  }) {
    final id = Uuid().v4();
    return Activity._(
      id: id,
      seriesId: id,
      title: title,
      startTime: startTime,
      endTime: endTime ?? startTime + duration,
      duration: duration,
      fileId: _nullIfEmpty(fileId),
      icon: _nullIfEmpty(fileId),
      category: category,
      deleted: false,
      fullDay: fullDay,
      recurrentType: recurrentType ?? 0,
      recurrentData: recurrentData ?? 0,
      revision: 0,
      reminderBefore: UnmodifiableListView(reminderBefore),
      alarmType: alarmType,
      infoItem: _nullIfEmpty(infoItem),
    );
  }

  Activity copyWith({
    String title,
    int startTime,
    int endTime,
    int duration,
    int category,
    Iterable<int> reminderBefore,
    String fileId,
    String icon,
    bool deleted,
    int revision,
    int alarmType,
    int recurrentType,
    int recurrentData,
    String infoItem,
  }) =>
      Activity._(
        id: id,
        seriesId: seriesId,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        duration: duration ?? this.duration,
        category: category ?? this.category,
        deleted: deleted ?? this.deleted,
        fullDay: fullDay ?? this.fullDay,
        recurrentType: recurrentType ?? this.recurrentType,
        recurrentData: recurrentData ?? this.recurrentData,
        reminderBefore: reminderBefore != null
            ? UnmodifiableListView(reminderBefore)
            : this.reminderBefore,
        fileId: fileId == null ? this.fileId : _nullIfEmpty(fileId),
        icon: fileId == null ? this.fileId : _nullIfEmpty(fileId),
        revision: revision ?? this.revision,
        alarmType: alarmType ?? this.alarmType,
        infoItem: infoItem == null ? this.infoItem : _nullIfEmpty(infoItem),
      );

  factory Activity.fromJson(Map<String, dynamic> json) => Activity._(
        id: json['id'],
        seriesId: json['seriesId'],
        title: json['title'],
        startTime: json['startTime'],
        endTime: json['endTime'],
        duration: json['duration'],
        fileId: _nullIfEmpty(json['fileId']),
        icon: _nullIfEmpty(json['icon']),
        infoItem: _nullIfEmpty(json['infoItem']),
        category: json['category'],
        deleted: json['deleted'],
        fullDay: json['fullDay'],
        recurrentType: json['recurrentType'],
        recurrentData: json['recurrentData'],
        reminderBefore: _parseReminders(json['reminderBefore']),
        revision: json['revision'],
        alarmType: json['alarmType'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'seriesId': seriesId,
        'title': title,
        'startTime': startTime,
        'endTime': endTime,
        'duration': duration,
        'fileId': fileId,
        'category': category,
        'deleted': deleted,
        'fullDay': fullDay,
        'recurrentType': recurrentType,
        'recurrentData': recurrentData,
        'reminderBefore': reminderBefore.map((r) => r.toString()).join(';'),
        'icon': icon,
        'infoItem': infoItem,
        'revision': revision,
        'alarmType': alarmType,
      };

  int get hashCode => id.hashCode;
  bool operator ==(o) => o is Activity && o.id == id;

  static String _nullIfEmpty(String value) =>
      value?.isNotEmpty == true ? value : null;

  static UnmodifiableListView<int> _parseReminders(String reminders) =>
      UnmodifiableListView(reminders
              ?.split(';')
              ?.map((t) => int.tryParse(t))
              ?.where((v) => v != null) ??
          []);

  @override
  List<Object> get props => [
        id,
        seriesId,
        title,
        startTime,
        endTime,
        duration,
        category,
        deleted,
        fullDay,
        recurrentType,
        recurrentData,
        revision,
        alarmType,
        reminderBefore,
        fileId,
        infoItem,
        icon,
      ];
  @override
  String toString() => [ 'Activity: { ',  props.map((p) => p.toString()).join(', '), ' }'].join();
}
