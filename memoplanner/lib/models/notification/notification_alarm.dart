import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:murmurhash/murmurhash.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

abstract class NotificationAlarm extends Equatable implements Trackable {
  final Event event;
  final bool fullScreenActivity;
  final bool reschedule;
  const NotificationAlarm(
    this.event, {
    required this.reschedule,
    this.fullScreenActivity = false,
  });
  bool hasSound(AlarmSettings settings);
  bool hasVibration(AlarmSettings settings);
  Sound sound(AlarmSettings settings);
  DateTime get notificationTime;
  String get stackId;
  String get type;
  String encode() => json.encode(toJson());
  factory NotificationAlarm.decode(String data) =>
      NotificationAlarm.fromJson(json.decode(data));
  factory NotificationAlarm.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'timer':
        final timer = AbiliaTimer.fromDbMap(json['timer']);
        return TimerAlarm(timer, reschedule: json['reschedule'] ?? false);
      default:
        return ActivityAlarm.fromJson(json);
    }
  }
  Map<String, dynamic> toJson();
  NotificationAlarm set({bool? fullScreenActivity, bool? reschedule});
  @override
  String toString() =>
      '$type {notificationTime: $notificationTime, ${event.id} -> $hashCode, reschedule: $reschedule}';
  @override
  List<Object?> get props => [event.id, notificationTime];
  @override
  // ignore: hash_and_equals
  int get hashCode =>
      MurmurHash.v3('${event.id}-${notificationTime.microsecondsSinceEpoch}', 1)
          .toSigned(32);

  @override
  Map<String, dynamic> get properties => {
        'type': type,
        'notificationTime': notificationTime,
        'fullScreenActivity': fullScreenActivity
      };
}

class TimerAlarm extends NotificationAlarm {
  final AbiliaTimer timer;
  const TimerAlarm(
    this.timer, {
    bool reschedule = false,
  }) : super(timer, reschedule: reschedule);

  @override
  final String type = 'timer';

  @override
  DateTime get notificationTime => timer.end;

  @override
  String get stackId => timer.id;

  @override
  bool hasSound(AlarmSettings settings) =>
      settings.timer.toSound() != Sound.NoSound;

  @override
  Sound sound(AlarmSettings settings) => settings.timer.toSound();

  @override
  bool hasVibration(AlarmSettings settings) =>
      settings.timerSound != Sound.NoSound;

  @override
  Map<String, dynamic> toJson() => {
        'timer': timer.toMapForDb(),
        'type': type.nullOnEmpty(),
        'reschedule': reschedule,
      };

  @override
  TimerAlarm set({bool? fullScreenActivity, bool? reschedule}) => TimerAlarm(
        timer,
        reschedule: reschedule ?? this.reschedule,
      );
}

abstract class ActivityAlarm extends NotificationAlarm {
  final ActivityDay activityDay;
  DateTime get day => activityDay.day;
  Activity get activity => activityDay.activity;

  @override
  String get stackId =>
      fullScreenActivity ? AlarmNavigator.fullScreenActivityKey : activity.id;

  const ActivityAlarm(
    this.activityDay, {
    required bool reschedule,
    bool fullScreenActivity = false,
  }) : super(
          activityDay,
          fullScreenActivity: fullScreenActivity,
          reschedule: reschedule,
        );

  @override
  Map<String, dynamic> toJson() => {
        'day': day.millisecondsSinceEpoch,
        'activity': activity.wrapWithDbModel().toJson(),
        'type': type.nullOnEmpty(),
        if (this is NewReminder)
          'reminder': (this as NewReminder).reminder.inMilliseconds,
        'reschedule': reschedule,
      };
  factory ActivityAlarm.fromJson(Map<String, dynamic> json) {
    final activity = DbActivity.fromJson(json['activity']).activity;
    final day = DateTime.fromMillisecondsSinceEpoch(json['day']);
    final activityDay = ActivityDay(activity, day);
    final reschedule = json['reschedule'] ?? false;
    switch (json['type']) {
      case StartAlarm.typeName:
        return StartAlarm(activityDay, reschedule: reschedule);
      case EndAlarm.typeName:
        return EndAlarm(activityDay, reschedule: reschedule);
      case ReminderBefore.typeName:
        return ReminderBefore(
          activityDay,
          reschedule: reschedule,
          reminder: Duration(milliseconds: json['reminder']),
        );
      case ReminderUnchecked.typeName:
        return ReminderUnchecked(
          activityDay,
          reschedule: reschedule,
          reminder: Duration(milliseconds: json['reminder']),
        );
      default:
        throw 'unknown alarm type';
    }
  }

  ActivityAlarm copyWith(ActivityDay activityDay);
}

abstract class NewAlarm extends ActivityAlarm {
  const NewAlarm(
    super.activityDay, {
    required super.reschedule,
    super.fullScreenActivity,
  });

  @override
  bool hasSound(settings) => activity.alarm.sound;

  @override
  bool hasVibration(AlarmSettings settings) => activity.alarm.vibrate;

  @override
  Sound sound(AlarmSettings settings) => activity.checkable
      ? settings.checkableActivity.toSound()
      : settings.nonCheckableActivity.toSound();

  AbiliaFile get speech;

  @override
  NewAlarm copyWith(ActivityDay activityDay);
}

class StartAlarm extends NewAlarm {
  const StartAlarm(
    super.activityDay, {
    super.reschedule = false,
    super.fullScreenActivity,
  });

  @override
  DateTime get notificationTime => activityDay.start;

  @override
  AbiliaFile get speech => activity.extras.startTimeExtraAlarm;

  @override
  StartAlarm set({
    bool? fullScreenActivity,
    bool? reschedule,
  }) =>
      StartAlarm(
        activityDay,
        fullScreenActivity: fullScreenActivity ?? this.fullScreenActivity,
        reschedule: reschedule ?? this.reschedule,
      );

  @override
  String get type => typeName;
  static const String typeName = 'StartAlarm';

  @override
  StartAlarm copyWith(ActivityDay activityDay) => StartAlarm(
        activityDay,
        fullScreenActivity: fullScreenActivity,
        reschedule: reschedule,
      );
}

class EndAlarm extends NewAlarm {
  const EndAlarm(
    super.activityDay, {
    super.reschedule = false,
    super.fullScreenActivity,
  });

  @override
  DateTime get notificationTime => activityDay.end;

  @override
  AbiliaFile get speech => activity.extras.endTimeExtraAlarm;

  @override
  String get type => typeName;

  @override
  EndAlarm set({
    bool? fullScreenActivity,
    bool? reschedule,
  }) =>
      EndAlarm(
        activityDay,
        fullScreenActivity: fullScreenActivity ?? this.fullScreenActivity,
        reschedule: reschedule ?? this.reschedule,
      );

  static const String typeName = 'EndAlarm';

  @override
  EndAlarm copyWith(ActivityDay activityDay) => EndAlarm(
        activityDay,
        fullScreenActivity: fullScreenActivity,
        reschedule: reschedule,
      );
}

abstract class NewReminder extends ActivityAlarm {
  final Duration reminder;
  const NewReminder(
    super.activityDay,
    this.reminder, {
    required super.reschedule,
  });

  @override
  bool hasSound(AlarmSettings settings) =>
      settings.reminder.toSound() != Sound.NoSound;

  @override
  bool hasVibration(AlarmSettings settings) =>
      settings.reminderSound != Sound.NoSound;

  @override
  Sound sound(AlarmSettings settings) => settings.reminder.toSound();

  @override
  NewReminder copyWith(ActivityDay activityDay);
}

class ReminderBefore extends NewReminder {
  const ReminderBefore(
    ActivityDay activityDay, {
    required Duration reminder,
    bool reschedule = false,
  }) : super(activityDay, reminder, reschedule: reschedule);
  @override
  DateTime get notificationTime => activityDay.start.subtract(reminder);

  @override
  ReminderBefore copyWith(ActivityDay activityDay) => ReminderBefore(
        activityDay,
        reschedule: reschedule,
        reminder: reminder,
      );

  @override
  String get type => typeName;
  static const String typeName = 'ReminderBefore';

  @override
  ReminderBefore set({bool? fullScreenActivity, bool? reschedule}) =>
      ReminderBefore(
        activityDay,
        reminder: reminder,
        reschedule: reschedule ?? this.reschedule,
      );
}

class ReminderUnchecked extends NewReminder {
  const ReminderUnchecked(
    ActivityDay activityDay, {
    required Duration reminder,
    bool reschedule = false,
  }) : super(activityDay, reminder, reschedule: reschedule);
  @override
  DateTime get notificationTime => activityDay.end.add(reminder);

  @override
  ReminderUnchecked copyWith(ActivityDay activityDay) => ReminderUnchecked(
        activityDay,
        reminder: reminder,
        reschedule: reschedule,
      );

  @override
  ReminderUnchecked set({bool? fullScreenActivity, bool? reschedule}) =>
      ReminderUnchecked(
        activityDay,
        reminder: reminder,
        reschedule: reschedule ?? this.reschedule,
      );

  @override
  String get type => typeName;
  static const String typeName = 'ReminderUnchecked';
}
