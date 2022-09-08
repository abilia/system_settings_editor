part of 'activity.dart';

class DbActivity extends DbModel<Activity> {
  Activity get activity => model;

  const DbActivity._({
    required Activity activity,
    required int dirty,
    required int revision,
  }) : super(revision: revision, dirty: dirty, model: activity);

  @override
  DbActivity copyWith({
    int? revision,
    int? dirty,
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
          title: json['title'] ?? '',
          startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
          duration: Duration(milliseconds: json['duration'] ?? 0),
          fileId: json['fileId'] ?? '',
          icon: json['icon'] ?? '',
          infoItemString: json['infoItem'] ?? '',
          category: json['category'] ?? 0,
          deleted: json['deleted'] ?? false,
          checkable: json['checkable'] ?? false,
          removeAfter: json['removeAfter'] ?? false,
          secret: json['secret'] ?? false,
          fullDay: json['fullDay'] ?? false,
          recurs: Recurs.raw(
            json['recurrentType'] ?? Recurs.typeNone,
            json['recurrentData'] ?? 0,
            json['endTime'],
          ),
          reminderBefore: parseReminders(json['reminderBefore']),
          alarmType: json['alarmType'],
          signedOffDates: _parseSignedOffDates(json['signedOffDates']),
          timezone: (json['timezone']?.isEmpty ?? true)
              ? tz.local.name
              : json['timezone'],
          extras: Extras.fromJsonString(json['extras']),
          calendarId: json['calendarId'] ?? '',
          secretExemptions: UnmodifiableSetView(
              exemptionsListToSet(json['secretExemptions'])),
        ),
        revision: json['revision'],
        dirty: 0,
      );

  static DbActivity fromDbMap(Map<String, dynamic> dbRow) => DbActivity._(
        activity: Activity._(
          id: dbRow['id'],
          seriesId: dbRow['series_id'],
          title: dbRow['title'] ?? '',
          startTime: DateTime.fromMillisecondsSinceEpoch(dbRow['start_time']),
          duration: Duration(milliseconds: dbRow['duration'] ?? 0),
          fileId: dbRow['file_id'] ?? '',
          icon: dbRow['icon'] ?? '',
          infoItemString: dbRow['info_item'],
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
          alarmType: dbRow['alarm_type'] ?? AlarmType.noAlarm,
          signedOffDates: _parseSignedOffDates(dbRow['signed_off_dates']),
          timezone: (dbRow['timezone']?.isEmpty ?? true)
              ? tz.local.name
              : dbRow['timezone'],
          extras: Extras.fromJsonString(dbRow['extras']),
          calendarId: dbRow['calendar_id'] ?? '',
          secretExemptions: _parseExemptions(dbRow['secret_exemptions']),
        ),
        revision: dbRow['revision'],
        dirty: dbRow['dirty'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': activity.id,
        'seriesId': activity.seriesId.nullOnEmpty(),
        'title': activity.title,
        'startTime': activity.startTime.millisecondsSinceEpoch,
        'endTime': activity.recurs.endTime,
        'duration': activity.duration.inMilliseconds,
        'fileId': activity.fileId.nullOnEmpty(),
        'category': activity.category,
        'deleted': activity.deleted,
        'checkable': activity.checkable,
        'removeAfter': activity.removeAfter,
        'secret': activity.secret,
        'fullDay': activity.fullDay,
        'recurrentType': activity.recurs.type,
        'recurrentData': activity.recurs.data,
        'reminderBefore': activity.reminderBefore.join(';'),
        'icon': activity.icon.nullOnEmpty(),
        'infoItem': activity.infoItemString,
        'alarmType': activity.alarmType,
        'signedOffDates': activity.signedOffDates.tryEncodeSignedOffDates(),
        'revision': revision,
        'timezone': activity.timezone,
        'extras': activity.extras.toJsonString().nullOnEmpty(),
        'secretExemptions': activity.secretExemptions.toList(),
        if (activity.calendarId.isNotEmpty)
          'calendarId': activity.calendarId.nullOnEmpty(),
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
        'info_item': activity.infoItemString,
        'alarm_type': activity.alarmType,
        'signed_off_dates': activity.signedOffDates.tryEncodeSignedOffDates(),
        'timezone': activity.timezone,
        'extras': activity.extras.toJsonString(),
        'calendar_id': activity.calendarId,
        'secret_exemptions': activity.secretExemptions.join(';'),
        'revision': revision,
        'dirty': dirty,
      };

  static UnmodifiableListView<String> _parseSignedOffDates(
          String? signedOffDates) =>
      UnmodifiableListView(signedOffDates?.tryDecodeSignedOffDates() ?? []);

  static UnmodifiableListView<int> parseReminders(String? reminders) =>
      UnmodifiableListView(reminders
              ?.split(';')
              .map(int.tryParse)
              .where((v) => v != null)
              .cast<int>() ??
          []);

  static Set<int> exemptionsListToSet(exemptions) =>
      exemptions is Iterable ? exemptions.whereType<int>().toSet() : {};

  static UnmodifiableSetView<int> _parseExemptions(String? secretExemptions) =>
      UnmodifiableSetView(secretExemptions
              ?.split(';')
              .map(int.tryParse)
              .where((v) => v != null)
              .cast<int>()
              .toSet() ??
          {});
  @override
  List<Object> get props => [activity, revision, dirty];

  @override
  String toString() =>
      'DbActivity: { revision: $revision, dirty: $dirty $activity }';
}
