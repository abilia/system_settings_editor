import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:uuid/uuid.dart';

class Activity extends DataModel {
  AlarmType get alarm => AlarmType.fromInt(alarmType);
  DateTime endClock(DateTime day) => startClock(day).add(duration);
  DateTime startClock(DateTime day) =>
      DateTime(day.year, day.month, day.day, startTime.hour, startTime.minute);
  DateTime get noneRecurringEnd => startTime.add(duration);
  bool get hasEndTime => duration.inMinutes > 0;
  RecurrentType get recurrance =>
      RecurrentType.values[recurrentType] ?? RecurrentType.none;
  bool get isRecurring => recurrance != RecurrentType.none;
  Iterable<Duration> get reminders =>
      reminderBefore.map((r) => r.milliseconds()).toSet();
  bool get hasImage =>
      (fileId?.isNotEmpty ?? false) || (icon?.isNotEmpty ?? false);
  bool get hasTitle => title?.isNotEmpty ?? false;
  bool get hasAttachment => infoItem != null;

  Activity signOff(DateTime day) => copyWith(
      signedOffDates: signedOffDates.contains(day)
          ? (signedOffDates.toList()..remove(day))
          : signedOffDates.followedBy([day]));

  final String seriesId, title, fileId, icon, timezone;
  final DateTime startTime, endTime;
  final Duration duration;
  final int category, alarmType, recurrentType, recurrentData;
  final bool deleted, fullDay, checkable, removeAfter, secret;
  final UnmodifiableListView<int> reminderBefore;
  final UnmodifiableListView<DateTime> signedOffDates;
  final InfoItem infoItem;
  const Activity._({
    @required String id,
    @required this.seriesId,
    @required this.title,
    @required this.startTime,
    @required this.endTime,
    @required this.duration,
    @required this.category,
    @required this.deleted,
    @required this.checkable,
    @required this.removeAfter,
    @required this.secret,
    @required this.alarmType,
    @required this.fullDay,
    @required this.recurrentType,
    @required this.recurrentData,
    @required this.reminderBefore,
    @required this.infoItem,
    @required this.icon,
    @required this.fileId,
    @required this.signedOffDates,
    @required this.timezone,
  })  : assert(title != null || fileId != null),
        assert(seriesId != null),
        assert(recurrentType >= 0 && recurrentType < 4),
        assert(alarmType >= 0),
        assert(startTime != null),
        assert(endTime != null),
        assert(duration != null),
        assert(category >= 0),
        assert(deleted != null),
        assert(checkable != null),
        assert(removeAfter != null),
        assert(secret != null),
        assert(fullDay != null),
        assert(recurrentData != null),
        assert(reminderBefore != null),
        assert(signedOffDates != null),
        super(id);

  static Activity createNew({
    @required String title,
    @required DateTime startTime,
    Duration duration = Duration.zero,
    int category = Category.right,
    DateTime endTime,
    int recurrentType = 0,
    int recurrentData = 0,
    bool fullDay = false,
    bool checkable = false,
    bool removeAfter = false,
    bool secret = false,
    int alarmType = ALARM_SOUND_AND_VIBRATION,
    InfoItem infoItem,
    String fileId,
    Iterable<int> reminderBefore = const [],
    Iterable<DateTime> signedOffDates = const [],
    String timezone,
  }) {
    final id = Uuid().v4();
    return Activity._(
      id: id,
      seriesId: id,
      title: title,
      startTime: startTime,
      endTime: endTime ?? startTime.add(duration),
      duration: duration,
      fileId: _nullIfEmpty(fileId),
      icon: _nullIfEmpty(fileId),
      category: category,
      deleted: false,
      checkable: checkable,
      removeAfter: removeAfter,
      secret: secret,
      fullDay: fullDay,
      recurrentType: recurrentType,
      recurrentData: recurrentData,
      reminderBefore: UnmodifiableListView(reminderBefore),
      alarmType: alarmType,
      infoItem: infoItem,
      signedOffDates: UnmodifiableListView(signedOffDates),
      timezone: timezone,
    );
  }

  @override
  DbActivity wrapWithDbModel({int revision = 0, int dirty = 0}) => DbActivity._(
        activity: this,
        dirty: dirty,
        revision: revision,
      );

  Activity copyWith({
    bool newId = false,
    String title,
    DateTime startTime,
    DateTime endTime,
    Duration duration,
    int category,
    Iterable<int> reminderBefore,
    String fileId,
    String icon,
    bool deleted,
    bool checkable,
    bool removeAfter,
    bool secret,
    bool fullDay,
    int alarmType,
    AlarmType alarm,
    int recurrentType,
    int recurrentData,
    InfoItem infoItem,
    Iterable<DateTime> signedOffDates,
    String timezone,
  }) =>
      Activity._(
        id: newId ? Uuid().v4() : id,
        seriesId: seriesId,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        duration: duration ?? this.duration,
        category: category ?? this.category,
        deleted: deleted ?? this.deleted,
        checkable: checkable ?? this.checkable,
        removeAfter: removeAfter ?? this.removeAfter,
        secret: secret ?? this.secret,
        fullDay: fullDay ?? this.fullDay,
        recurrentType: recurrentType ?? this.recurrentType,
        recurrentData: recurrentData ?? this.recurrentData,
        reminderBefore: reminderBefore != null
            ? UnmodifiableListView(reminderBefore)
            : this.reminderBefore,
        fileId: fileId == null ? this.fileId : _nullIfEmpty(fileId),
        icon: icon == null ? this.icon : _nullIfEmpty(icon),
        alarmType: alarmType ?? alarm?.toInt ?? this.alarmType,
        infoItem: infoItem ?? this.infoItem,
        signedOffDates: signedOffDates != null
            ? UnmodifiableListView(signedOffDates)
            : this.signedOffDates,
        timezone: timezone ?? this.timezone,
      );

  Activity copyActivity(Activity other) => copyWith(
        title: other.title,
        startTime: startTime.copyWith(
            hour: other.startTime.hour, minute: other.startTime.minute),
        duration: other.duration,
        category: other.category,
        checkable: other.checkable,
        removeAfter: other.removeAfter,
        secret: other.secret,
        fullDay: other.fullDay,
        reminderBefore: other.reminderBefore,
        fileId: other.fileId ?? '',
        icon: other.icon ?? '',
        alarmType: other.alarmType,
        infoItem: other.infoItem,
        timezone: other.timezone,
      );

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
        checkable,
        removeAfter,
        secret,
        fullDay,
        recurrentType,
        recurrentData,
        alarmType,
        reminderBefore,
        fileId,
        infoItem,
        icon,
        signedOffDates,
        timezone,
      ];
  @override
  String toString() => 'Activity: { ${props.join(', ')} }';
}

class DbActivity extends DbModel<Activity> {
  Activity get activity => model;
  const DbActivity._({
    Activity activity,
    int dirty,
    int revision,
  }) : super(revision: revision, dirty: dirty, model: activity);

  @override
  DbActivity copyWith({
    int revision,
    int dirty,
  }) =>
      DbActivity._(
        activity: activity,
        revision: revision ?? this.revision,
        dirty: dirty ?? this.dirty,
      );

  static DbActivity fromJson(Map<String, dynamic> json) => DbActivity._(
        activity: Activity._(
          id: json['id'],
          seriesId: json['seriesId'],
          title: json['title'],
          startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
          endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime']),
          duration: Duration(milliseconds: json['duration']),
          fileId: _nullIfEmpty(json['fileId']),
          icon: _nullIfEmpty(json['icon']),
          infoItem: InfoItem.fromBase64(json['infoItem']),
          category: json['category'],
          deleted: json['deleted'],
          checkable: json['checkable'],
          removeAfter: json['removeAfter'],
          secret: json['secret'],
          fullDay: json['fullDay'],
          recurrentType: json['recurrentType'],
          recurrentData: json['recurrentData'],
          reminderBefore: _parseReminders(json['reminderBefore']),
          alarmType: json['alarmType'],
          signedOffDates: _parseSignedOffDates(json['signedOffDates']),
          timezone: json['timezone'],
        ),
        revision: json['revision'],
        dirty: 0,
      );

  static DbActivity fromDbMap(Map<String, dynamic> dbRow) => DbActivity._(
        activity: Activity._(
          id: dbRow['id'],
          seriesId: dbRow['series_id'],
          title: dbRow['title'],
          startTime: DateTime.fromMillisecondsSinceEpoch(dbRow['start_time']),
          endTime: DateTime.fromMillisecondsSinceEpoch(dbRow['end_time']),
          duration: Duration(milliseconds: dbRow['duration']),
          fileId: _nullIfEmpty(dbRow['file_id']),
          icon: _nullIfEmpty(dbRow['icon']),
          infoItem: InfoItem.fromBase64(dbRow['info_item']),
          category: dbRow['category'],
          deleted: dbRow['deleted'] == 1,
          checkable: dbRow['checkable'] == 1,
          removeAfter: dbRow['remove_after'] == 1,
          secret: dbRow['secret'] == 1,
          fullDay: dbRow['full_day'] == 1,
          recurrentType: dbRow['recurrent_type'],
          recurrentData: dbRow['recurrent_data'],
          reminderBefore: _parseReminders(dbRow['reminder_before']),
          alarmType: dbRow['alarm_type'],
          signedOffDates: _parseSignedOffDates(dbRow['signed_off_dates']),
          timezone: dbRow['timezone'],
        ),
        revision: dbRow['revision'],
        dirty: dbRow['dirty'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': activity.id,
        'seriesId': activity.seriesId,
        'title': activity.title,
        'startTime': activity.startTime.millisecondsSinceEpoch,
        'endTime': activity.endTime.millisecondsSinceEpoch,
        'duration': activity.duration.inMilliseconds,
        'fileId': activity.fileId,
        'category': activity.category,
        'deleted': activity.deleted,
        'checkable': activity.checkable,
        'removeAfter': activity.removeAfter,
        'secret': activity.secret,
        'fullDay': activity.fullDay,
        'recurrentType': activity.recurrentType,
        'recurrentData': activity.recurrentData,
        'reminderBefore': activity.reminderBefore.join(';'),
        'icon': activity.icon,
        'infoItem': activity.infoItem?.toBase64(),
        'alarmType': activity.alarmType,
        'signedOffDates': activity.signedOffDates.tryEncodeSignedOffDates(),
        'revision': revision,
        'timezone': activity.timezone,
      };

  @override
  Map<String, dynamic> toMapForDb() => {
        'id': activity.id,
        'series_id': activity.seriesId,
        'title': activity.title,
        'start_time': activity.startTime.millisecondsSinceEpoch,
        'end_time': activity.endTime.millisecondsSinceEpoch,
        'duration': activity.duration.inMilliseconds,
        'file_id': activity.fileId,
        'category': activity.category,
        'deleted': activity.deleted ? 1 : 0,
        'checkable': activity.checkable ? 1 : 0,
        'remove_after': activity.removeAfter ? 1 : 0,
        'secret': activity.secret ? 1 : 0,
        'full_day': activity.fullDay ? 1 : 0,
        'recurrent_type': activity.recurrentType,
        'recurrent_data': activity.recurrentData,
        'reminder_before': activity.reminderBefore.join(';'),
        'icon': activity.icon,
        'info_item': activity.infoItem?.toBase64(),
        'alarm_type': activity.alarmType,
        'signed_off_dates': activity.signedOffDates.tryEncodeSignedOffDates(),
        'timezone': activity.timezone,
        'revision': revision,
        'dirty': dirty,
      };
  static UnmodifiableListView<DateTime> _parseSignedOffDates(signedOffDates) =>
      UnmodifiableListView(
          (signedOffDates as String)?.tryDecodeSignedOffDates() ?? []);

  static UnmodifiableListView<int> _parseReminders(String reminders) =>
      UnmodifiableListView(
          reminders?.split(';')?.map(int.tryParse)?.where((v) => v != null) ??
              []);
  @override
  List<Object> get props => [activity, revision, dirty];

  @override
  String toString() =>
      'DbActivity: { revision: $revision, dirty: $dirty $activity }';
}

String _nullIfEmpty(String value) => value?.isNotEmpty == true ? value : null;

class TimeInterval extends Equatable {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  bool get sameTime => startTime == endTime;
  bool get startTimeSet => startTime != null;
  bool get endTimeSet => endTime != null;
  bool get onlyStartTime => startTimeSet && !endTimeSet;
  bool get onlyEndTime => endTimeSet && !startTimeSet;

  TimeInterval(this.startTime, this.endTime);

  TimeInterval.fromDateTime(DateTime startDate, DateTime endDate)
      : startTime =
            startDate != null ? TimeOfDay.fromDateTime(startDate) : null,
        endTime = endDate != null ? TimeOfDay.fromDateTime(endDate) : null;

  TimeInterval.empty()
      : startTime = null,
        endTime = null;

  @override
  List<Object> get props => [startTime, endTime];

  @override
  String toString() => 'TimeInterval: $startTime - $endTime';
}
