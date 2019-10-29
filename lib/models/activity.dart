import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:seagull/models/alarm_type.dart';
import 'package:uuid/uuid.dart';

class Activity extends Equatable {
  AlarmType get alarm => AlarmType.fromInt(alarmType);
  DateTime get startDate => DateTime.fromMillisecondsSinceEpoch(startTime);
  DateTime get endDate => DateTime.fromMillisecondsSinceEpoch(startTime + duration);
  final String id, seriesId, title, fileId, icon;
  final int startTime, duration, category, revision, alarmType;
  final bool deleted;
  final UnmodifiableListView<int> reminderBefore;
  const Activity._({
    @required this.id,
    @required this.seriesId,
    @required this.title,
    @required this.startTime,
    @required this.duration,
    @required this.category,
    @required this.deleted,
    @required this.revision,
    @required this.alarmType,
    this.reminderBefore,
    this.fileId,
    this.icon,
  })  : assert(title != null || fileId != null),
        assert(id != null),
        assert(seriesId != null),
        assert(revision != null),
        assert(alarmType != null),
        assert(startTime > 0);

  factory Activity.createNew(
      {@required String title,
      @required int startTime,
      @required int duration,
      @required int category,
      @required Iterable<int> reminderBefore,
      int alarmType,
      String fileId}) {
    final id = Uuid().v4();
    return Activity._(
      id: id,
      seriesId: id,
      title: title,
      startTime: startTime,
      duration: duration,
      fileId: nullIfEmpty(fileId),
      icon: nullIfEmpty(fileId),
      category: category,
      deleted: false,
      revision: 0,
      reminderBefore: UnmodifiableListView(reminderBefore),
      alarmType: alarmType ?? ALARM_SOUND_AND_VIBRATION_ONLY_ON_START,
    );
  }

  Activity copyWith({
    String title,
    int startTime,
    int duration,
    int category,
    Iterable<int> reminderBefore,
    String fileId,
    String icon,
    bool deleted,
    int revision,
    int alarmType,
  }) =>
      Activity._(
        id: id,
        seriesId: seriesId,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
        category: category ?? this.category,
        deleted: deleted ?? this.deleted,
        reminderBefore: reminderBefore != null
            ? UnmodifiableListView(reminderBefore)
            : this.reminderBefore,
        fileId: fileId == null ? this.fileId : nullIfEmpty(fileId),
        icon: fileId == null ? this.fileId : nullIfEmpty(fileId),
        revision: revision ?? this.revision,
        alarmType: alarmType ?? this.alarmType,
      );

  factory Activity.fromJson(Map<String, dynamic> json) => Activity._(
        id: json['id'],
        seriesId: json['seriesId'],
        title: json['title'],
        startTime: json['startTime'],
        duration: json['duration'],
        fileId: nullIfEmpty(json['fileId']),
        icon: nullIfEmpty(json['icon']),
        category: json['category'],
        deleted: json['deleted'],
        reminderBefore: _parseReminders(json['reminderBefore']),
        revision: json['revision'],
        alarmType: json['alarmType'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'seriesId': seriesId,
        'title': title,
        'startTime': startTime,
        'endTime': startTime + duration,
        'duration': duration,
        'fileId': fileId,
        'category': category,
        'deleted': deleted,
        'reminderBefore': reminderBefore.map((r) => r.toString()).join(';'),
        'icon': icon,
        'revision': revision,
        'alarmType': alarmType,
      };

  int get hashCode => id.hashCode;
  bool operator ==(o) => o is Activity && o.id == id;

  static String nullIfEmpty(String value) =>
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
        duration,
        category,
        deleted,
        revision,
        alarmType,
        reminderBefore,
        fileId,
        icon,
      ];
      @override String toString() => props.map((p) => p.toString()).join(',');
}
