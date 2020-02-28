import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:uuid/uuid.dart';

class Activity extends Equatable {
  AlarmType get alarm => AlarmType.fromInt(alarmType);
  DateTime endClock(DateTime day) =>
      startClock(day).add(duration.milliseconds());
  DateTime startClock(DateTime day) => DateTime(
      day.year, day.month, day.day, startDateTime.hour, startDateTime.minute);
  DateTime get start => startDateTime;
  DateTime get end => DateTime.fromMillisecondsSinceEpoch(startTime + duration);
  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(startTime);
  DateTime get endDateTime => DateTime.fromMillisecondsSinceEpoch(endTime);
  bool get hasEndTime => !start.isAtSameMomentAs(end);
  RecurrentType get recurrance => RecurrentType.values[recurrentType];
  Iterable<Duration> get reminders =>
      reminderBefore.map((r) => r.milliseconds());
  bool isSignedOff(DateTime day) => checkable && signedOffDates.contains(day);
  bool get hasImage =>
      (fileId?.isNotEmpty ?? false) || (icon?.isNotEmpty ?? false);

  Activity signOff(DateTime day) => copyWith(
      signedOffDates: signedOffDates.contains(day)
          ? (signedOffDates.toList()..remove(day))
          : signedOffDates.followedBy([day]));

  final String id, seriesId, title, fileId, icon, infoItem;
  final int startTime,
      endTime,
      duration,
      category,
      alarmType,
      recurrentType,
      recurrentData;
  final bool deleted, fullDay, checkable, removeAfter, secret;
  final UnmodifiableListView<int> reminderBefore;
  final UnmodifiableListView<DateTime> signedOffDates;
  const Activity._({
    @required this.id,
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
  })  : assert(title != null || fileId != null),
        assert(id != null),
        assert(seriesId != null),
        assert(recurrentType >= 0 && recurrentType < 4),
        assert(alarmType >= 0),
        assert(startTime > 0),
        assert(endTime > 0),
        assert(duration >= 0),
        assert(category >= 0),
        assert(deleted != null),
        assert(checkable != null),
        assert(removeAfter != null),
        assert(secret != null),
        assert(fullDay != null),
        assert(recurrentData != null),
        assert(reminderBefore != null),
        assert(signedOffDates != null);

  static Activity createNew({
    @required String title,
    @required int startTime,
    int duration = 0,
    int category = 0,
    int endTime,
    int recurrentType = 0,
    int recurrentData = 0,
    bool fullDay = false,
    bool checkable = false,
    bool removeAfter = false,
    bool secret = false,
    int alarmType = ALARM_SOUND_AND_VIBRATION_ONLY_ON_START,
    String infoItem,
    String fileId,
    Iterable<int> reminderBefore = const [],
    Iterable<DateTime> signedOffDates = const [],
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
      checkable: checkable,
      removeAfter: removeAfter,
      secret: secret,
      fullDay: fullDay,
      recurrentType: recurrentType,
      recurrentData: recurrentData,
      reminderBefore: UnmodifiableListView(reminderBefore),
      alarmType: alarmType,
      infoItem: _nullIfEmpty(infoItem),
      signedOffDates: UnmodifiableListView(signedOffDates),
    );
  }

  DbActivity asDbActivity({int revision = 0, int dirty = 0}) => DbActivity._(
        activity: this,
        dirty: dirty,
        revision: revision,
      );

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
    bool checkable,
    bool removeAfter,
    bool secret,
    bool fullDay,
    int revision,
    int alarmType,
    AlarmType alarm,
    int recurrentType,
    int recurrentData,
    String infoItem,
    Iterable<DateTime> signedOffDates,
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
        icon: fileId == null ? this.fileId : _nullIfEmpty(fileId),
        alarmType: alarmType ?? alarm?.toInt ?? this.alarmType,
        infoItem: infoItem == null ? this.infoItem : _nullIfEmpty(infoItem),
        signedOffDates: signedOffDates != null
            ? UnmodifiableListView(signedOffDates)
            : this.signedOffDates,
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
      ];
  @override
  String toString() => 'Activity: { ${props.join(', ')} }';
}

class DbActivity extends Equatable {
  final Activity activity;
  final int revision, dirty;
  const DbActivity._({
    @required this.activity,
    @required this.dirty,
    @required this.revision,
  })  : assert(activity != null),
        assert(dirty != null),
        assert(dirty >= 0),
        assert(revision != null),
        assert(revision >= 0);

  DbActivity copyWith({
    int revision,
    int dirty,
  }) =>
      DbActivity._(
        activity: this.activity,
        revision: revision ?? this.revision,
        dirty: dirty ?? this.dirty,
      );

  static DbActivity fromJson(Map<String, dynamic> json) => DbActivity._(
        activity: Activity._(
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
          checkable: json['checkable'],
          removeAfter: json['removeAfter'],
          secret: json['secret'],
          fullDay: json['fullDay'],
          recurrentType: json['recurrentType'],
          recurrentData: json['recurrentData'],
          reminderBefore: _parseReminders(json['reminderBefore']),
          alarmType: json['alarmType'],
          signedOffDates: _parseSignedOffDates(json['signedOffDates']),
        ),
        revision: json['revision'],
        dirty: 0,
      );

  static DbActivity fromDbMap(Map<String, dynamic> dbRow) => DbActivity._(
        activity: Activity._(
          id: dbRow['id'],
          seriesId: dbRow['series_id'],
          title: dbRow['title'],
          startTime: dbRow['start_time'],
          endTime: dbRow['end_time'],
          duration: dbRow['duration'],
          fileId: _nullIfEmpty(dbRow['file_id']),
          icon: _nullIfEmpty(dbRow['icon']),
          infoItem: _nullIfEmpty(dbRow['info_item']),
          category: dbRow['category'],
          deleted: dbRow['deleted'] == 1 ? true : false,
          checkable: dbRow['checkable'] == 1 ? true : false,
          removeAfter: dbRow['remove_after'] == 1 ? true : false,
          secret: dbRow['secret'] == 1 ? true : false,
          fullDay: dbRow['full_day'] == 1 ? true : false,
          recurrentType: dbRow['recurrent_type'],
          recurrentData: dbRow['recurrent_data'],
          reminderBefore: _parseReminders(dbRow['reminder_before']),
          alarmType: dbRow['alarm_type'],
          signedOffDates: _parseSignedOffDates(dbRow['signed_off_dates']),
        ),
        revision: dbRow['revision'],
        dirty: dbRow['dirty'],
      );

  Map<String, dynamic> toJson() => {
        'id': activity.id,
        'seriesId': activity.seriesId,
        'title': activity.title,
        'startTime': activity.startTime,
        'endTime': activity.endTime,
        'duration': activity.duration,
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
        'infoItem': activity.infoItem,
        'alarmType': activity.alarmType,
        'signedOffDates': activity.signedOffDates.tryEncodeSignedOffDates(),
        'revision': revision,
      };

  Map<String, dynamic> toMapForDb() => {
        'id': activity.id,
        'series_id': activity.seriesId,
        'title': activity.title,
        'start_time': activity.startTime,
        'end_time': activity.endTime,
        'duration': activity.duration,
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
        'info_item': activity.infoItem,
        'alarm_type': activity.alarmType,
        'signed_off_dates': activity.signedOffDates.tryEncodeSignedOffDates(),
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
