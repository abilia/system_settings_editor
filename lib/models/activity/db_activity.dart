part of 'activity.dart';

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
          recurs: Recurs.raw(
            json['recurrentType'],
            json['recurrentData'],
            json['endTime'],
          ),
          reminderBefore: parseReminders(json['reminderBefore']),
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
          recurs: Recurs.raw(
            dbRow['recurrent_type'],
            dbRow['recurrent_data'],
            dbRow['end_time'],
          ),
          reminderBefore: parseReminders(dbRow['reminder_before']),
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
        'endTime': activity.recurs.endTime,
        'duration': activity.duration.inMilliseconds,
        'fileId': activity.fileId,
        'category': activity.category,
        'deleted': activity.deleted,
        'checkable': activity.checkable,
        'removeAfter': activity.removeAfter,
        'secret': activity.secret,
        'fullDay': activity.fullDay,
        'recurrentType': activity.recurs.type,
        'recurrentData': activity.recurs.data,
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
        'end_time': activity.recurs.endTime,
        'duration': activity.duration.inMilliseconds,
        'file_id': activity.fileId,
        'category': activity.category,
        'deleted': activity.deleted ? 1 : 0,
        'checkable': activity.checkable ? 1 : 0,
        'remove_after': activity.removeAfter ? 1 : 0,
        'secret': activity.secret ? 1 : 0,
        'full_day': activity.fullDay ? 1 : 0,
        'recurrent_type': activity.recurs.type,
        'recurrent_data': activity.recurs.data,
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

  static UnmodifiableListView<int> parseReminders(String reminders) =>
      UnmodifiableListView(
          reminders?.split(';')?.map(int.tryParse)?.where((v) => v != null) ??
              []);

  @override
  List<Object> get props => [activity, revision, dirty];

  @override
  String toString() =>
      'DbActivity: { revision: $revision, dirty: $dirty $activity }';
}
