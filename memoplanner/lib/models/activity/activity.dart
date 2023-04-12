import 'dart:collection';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/timezone.dart' as tz;
import 'package:memoplanner/utils/all.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'activity_extras.dart';
part 'db_activity.dart';
part 'recurs.dart';

class Activity extends DataModel {
  DateTime endClock(DateTime day) => fullDay
      ? day.nextDay().millisecondBefore()
      : startClock(day).add(duration);

  DateTime startClock(DateTime day) =>
      DateTime(day.year, day.month, day.day, startTime.hour, startTime.minute);

  bool get hasEndTime => duration.inMinutes > 0;

  bool get isRecurring => recurs.isRecurring;

  bool get hasImage => fileId.isNotEmpty || icon.isNotEmpty;

  bool get hasTitle => title.isNotEmpty;

  bool get hasAttachment => infoItemString.isNotEmpty;

  bool get isNoneSingleInstanceRecurring =>
      recurs.isRecurring && !startTime.isAtSameDay(recurs.end);

  AvailableForType get availableFor => !secret
      ? AvailableForType.allSupportPersons
      : secretExemptions.isEmpty
          ? AvailableForType.onlyMe
          : AvailableForType.selectedSupportPersons;

  Activity signOff(DateTime day) {
    final d = whaleDateFormat(day);
    return copyWith(
      signedOffDates: signedOffDates.contains(d)
          ? (signedOffDates.toList()..remove(d))
          : signedOffDates.followedBy([d]),
    );
  }

  final String seriesId, title, fileId, icon, timezone, calendarId;
  final DateTime startTime;
  final Duration duration;
  final int category, alarmType;
  final bool fullDay, checkable, removeAfter, secret;
  final UnmodifiableListView<int> reminderBefore;
  final UnmodifiableListView<String> signedOffDates;
  final String infoItemString;
  final Recurs recurs;
  final Extras extras;
  final UnmodifiableSetView<int> secretExemptions;

  late final DateTime noneRecurringEnd = startTime.add(duration);
  late final UnmodifiableSetView<Duration> reminders = UnmodifiableSetView(
    reminderBefore.map((ms) => Duration(milliseconds: ms)).toSet(),
  );
  late final Alarm alarm = Alarm.fromInt(alarmType);
  late final InfoItem infoItem = InfoItem.fromBase64(infoItemString);

  Activity._({
    required super.id,
    required super.deleted,
    required this.seriesId,
    required this.title,
    required this.startTime,
    required this.duration,
    required this.category,
    required this.checkable,
    required this.removeAfter,
    required this.secret,
    required this.alarmType,
    required this.fullDay,
    required this.recurs,
    required this.reminderBefore,
    required this.infoItemString,
    required this.icon,
    required this.fileId,
    required this.signedOffDates,
    required this.timezone,
    required this.extras,
    required this.calendarId,
    required this.secretExemptions,
  })  : assert(alarmType >= 0),
        assert(category >= 0);

  factory Activity({
    required DateTime startTime,
    required String timezone,
    required String calendarId,
    String title = '',
    Duration duration = Duration.zero,
    int category = Category.right,
    Recurs recurs = Recurs.not,
    bool fullDay = false,
    bool checkable = false,
    bool removeAfter = false,
    bool secret = false,
    int alarmType = alarmSoundAndVibration,
    String infoItemString = '',
    String fileId = '',
    String icon = '',
    Iterable<int> reminderBefore = const [],
    Iterable<String> signedOffDates = const [],
    Extras extras = Extras.empty,
    Set<int> secretExemptions = const {},
  }) {
    final id = const Uuid().v4();
    return Activity._(
      id: id,
      seriesId: id,
      title: title,
      startTime: startTime,
      duration: duration,
      fileId: fileId,
      icon: icon,
      category: category,
      deleted: false,
      checkable: checkable,
      removeAfter: removeAfter,
      secret: secret,
      fullDay: fullDay,
      recurs: _newRecurrence(recurs, startTime, duration, fullDay),
      reminderBefore: UnmodifiableListView(reminderBefore),
      alarmType: alarmType,
      infoItemString: infoItemString,
      signedOffDates: UnmodifiableListView(signedOffDates),
      timezone: timezone,
      extras: extras,
      calendarId: calendarId,
      secretExemptions: UnmodifiableSetView(secretExemptions),
    );
  }

  @visibleForTesting
  factory Activity.createNew({
    required DateTime startTime,
    String title = '',
    Duration duration = Duration.zero,
    int category = Category.right,
    Recurs recurs = Recurs.not,
    bool fullDay = false,
    bool checkable = false,
    bool removeAfter = false,
    bool secret = false,
    int alarmType = alarmSoundAndVibration,
    InfoItem infoItem = const NoInfoItem(),
    String fileId = '',
    String icon = '',
    Iterable<int> reminderBefore = const [],
    Iterable<String> signedOffDates = const [],
    String timezone = '',
    Extras extras = Extras.empty,
    String calendarId = '',
    Set<int> secretExemptions = const {},
  }) =>
      Activity(
        title: title,
        startTime: startTime,
        duration: duration,
        fileId: fileId,
        icon: icon,
        category: category,
        checkable: checkable,
        removeAfter: removeAfter,
        secret: secret,
        fullDay: fullDay,
        recurs: recurs,
        reminderBefore: reminderBefore,
        alarmType: alarmType,
        infoItemString: infoItem.toBase64(),
        signedOffDates: signedOffDates,
        timezone: timezone,
        extras: extras,
        calendarId: calendarId,
        secretExemptions: secretExemptions,
      );

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
    String? title,
    DateTime? startTime,
    Duration? duration,
    int? category,
    Iterable<int>? reminderBefore,
    String? fileId,
    String? icon,
    bool? deleted,
    bool? checkable,
    bool? removeAfter,
    bool? secret,
    bool? fullDay,
    int? alarmType,
    Alarm? alarm,
    Recurs? recurs,
    InfoItem? infoItem,
    Iterable<String>? signedOffDates,
    String? timezone,
    Extras? extras,
    String? calendarId,
    Set<int>? secretExemptions,
  }) =>
      Activity._(
        id: newId ? const Uuid().v4() : id,
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
        recurs: _newRecurrence(
          recurs ?? this.recurs,
          startTime ?? this.startTime,
          duration ?? this.duration,
          fullDay ?? this.fullDay,
        ),
        reminderBefore: reminderBefore != null
            ? UnmodifiableListView(reminderBefore)
            : this.reminderBefore,
        fileId: fileId ?? this.fileId,
        icon: icon ?? this.icon,
        alarmType: alarmType ?? alarm?.intValue ?? this.alarmType,
        infoItemString: infoItem?.toBase64() ?? infoItemString,
        signedOffDates: signedOffDates != null
            ? UnmodifiableListView(signedOffDates)
            : this.signedOffDates,
        timezone: timezone ?? this.timezone,
        extras: extras ?? this.extras,
        calendarId: calendarId ?? this.calendarId,
        secretExemptions: secretExemptions != null
            ? UnmodifiableSetView(secretExemptions)
            : this.secretExemptions,
      );

  static Recurs _newRecurrence(
    Recurs recurs,
    DateTime startTime,
    Duration duration,
    bool fullDay,
  ) {
    if (recurs.isRecurring) return recurs;
    if (fullDay) {
      return recurs
          .changeEnd(startTime.onlyDays().nextDay().millisecondBefore());
    }
    return recurs.changeEnd(startTime.add(duration));
  }

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
        fileId: other.fileId,
        icon: other.icon,
        alarmType: other.alarmType,
        infoItem: other.infoItem,
        timezone: other.timezone,
        recurs:
            recurs.isRecurring ? other.recurs.changeEnd(recurs.end) : recurs,
        extras: other.extras,
        calendarId: other.calendarId,
        secretExemptions: other.secretExemptions,
      );

  @override
  List<Object> get props => [
        id,
        seriesId,
        title,
        startTime.millisecondsSinceEpoch,
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
        infoItemString,
        icon,
        signedOffDates,
        timezone,
        extras,
        calendarId,
        secretExemptions,
      ];

  @override
  bool get stringify => true;
}

enum AvailableForType {
  onlyMe,
  allSupportPersons,
  selectedSupportPersons,
}
