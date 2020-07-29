import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'recurs.dart';
part 'db_activity.dart';

class Activity extends DataModel {
  AlarmType get alarm => AlarmType.fromInt(alarmType);
  DateTime endClock(DateTime day) => startClock(day).add(duration);
  DateTime startClock(DateTime day) =>
      DateTime(day.year, day.month, day.day, startTime.hour, startTime.minute);
  DateTime get noneRecurringEnd => startTime.add(duration);
  bool get hasEndTime => duration.inMinutes > 0;
  bool get isRecurring => recurs.recurrance != RecurrentType.none;
  Iterable<Duration> get reminders =>
      reminderBefore.map((r) => r.milliseconds()).toSet();
  bool get hasImage =>
      (fileId?.isNotEmpty ?? false) || (icon?.isNotEmpty ?? false);
  bool get hasTitle => title?.isNotEmpty ?? false;
  bool get hasAttachment => infoItem is! NoInfoItem;

  Activity signOff(DateTime day) => copyWith(
      signedOffDates: signedOffDates.contains(day)
          ? (signedOffDates.toList()..remove(day))
          : signedOffDates.followedBy([day]));

  final String seriesId, title, fileId, icon, timezone;
  final DateTime startTime;
  final Duration duration;
  final int category, alarmType;
  final bool deleted, fullDay, checkable, removeAfter, secret;
  final UnmodifiableListView<int> reminderBefore;
  final UnmodifiableListView<DateTime> signedOffDates;
  final InfoItem infoItem;
  final Recurs recurs;
  const Activity._({
    @required String id,
    @required this.seriesId,
    @required this.title,
    @required this.startTime,
    @required this.duration,
    @required this.category,
    @required this.deleted,
    @required this.checkable,
    @required this.removeAfter,
    @required this.secret,
    @required this.alarmType,
    @required this.fullDay,
    @required this.recurs,
    @required this.reminderBefore,
    @required this.infoItem,
    @required this.icon,
    @required this.fileId,
    @required this.signedOffDates,
    @required this.timezone,
  })  : assert(title != null || fileId != null),
        assert(seriesId != null),
        assert(alarmType >= 0),
        assert(startTime != null),
        assert(duration != null),
        assert(category >= 0),
        assert(deleted != null),
        assert(checkable != null),
        assert(removeAfter != null),
        assert(secret != null),
        assert(fullDay != null),
        assert(recurs != null),
        assert(infoItem != null),
        assert(reminderBefore != null),
        assert(signedOffDates != null),
        super(id);

  static Activity createNew({
    @required String title,
    @required DateTime startTime,
    Duration duration = Duration.zero,
    int category = Category.right,
    Recurs recurs = Recurs.not,
    bool fullDay = false,
    bool checkable = false,
    bool removeAfter = false,
    bool secret = false,
    int alarmType = ALARM_SOUND_AND_VIBRATION,
    InfoItem infoItem = const NoInfoItem(),
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
      duration: duration,
      fileId: _nullIfEmpty(fileId),
      icon: _nullIfEmpty(fileId),
      category: category,
      deleted: false,
      checkable: checkable,
      removeAfter: removeAfter,
      secret: secret,
      fullDay: fullDay,
      recurs: recurs,
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

  Activity copyWithRecurringEnd(DateTime endTime, {bool newId = false}) =>
      copyWith(
        newId: newId,
        recurs: recurs.changeEnd(endTime),
      );

  Activity copyWith({
    bool newId = false,
    String title,
    DateTime startTime,
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
    Recurs recurs,
    InfoItem infoItem,
    Iterable<DateTime> signedOffDates,
    String timezone,
  }) =>
      Activity._(
        id: newId ? Uuid().v4() : id,
        seriesId: seriesId,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
        category: category ?? this.category,
        deleted: deleted ?? this.deleted,
        checkable: checkable ?? this.checkable,
        removeAfter: removeAfter ?? this.removeAfter,
        secret: secret ?? this.secret,
        fullDay: fullDay ?? this.fullDay,
        recurs: recurs ?? this.recurs,
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
        duration,
        category,
        deleted,
        checkable,
        removeAfter,
        secret,
        fullDay,
        recurs,
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

String _nullIfEmpty(String value) => value?.isNotEmpty == true ? value : null;
