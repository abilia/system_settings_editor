import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:seagull/models/all.dart';

abstract class NotificationAlarm extends Equatable {
  final Event event;
  const NotificationAlarm(this.event);
  bool hasSound(AlarmSettings settings);
  bool vibrate(AlarmSettings settings);
  Sound sound(AlarmSettings settings);
  DateTime get notificationTime;
  String get type;
  String get stackId;

  factory NotificationAlarm.decode(String data) =>
      ActivityAlarm.fromJson(json.decode(data));
  @override
  String toString() =>
      '$type {notificationTime: $notificationTime, ${event.id} }';
}

abstract class ActivityAlarm extends NotificationAlarm {
  final ActivityDay activityDay;
  final bool fullScreenActivity;
  DateTime get day => activityDay.day;
  Activity get activity => activityDay.activity;

  @override
  String get stackId => fullScreenActivity ? 'fullScreenActivity' : activity.id;

  const ActivityAlarm(
    this.activityDay, {
    this.fullScreenActivity = false,
  }) : super(activityDay);

  Map<String, dynamic> toJson() => {
        'day': day.millisecondsSinceEpoch,
        'activity': activity.wrapWithDbModel().toJson(),
        'type': type,
        if (this is NewReminder)
          'reminder': (this as NewReminder).reminder.inMilliseconds,
      };

  factory ActivityAlarm.fromJson(Map<String, dynamic> json) {
    final activity = DbActivity.fromJson(json['activity']).activity;
    final day = DateTime.fromMillisecondsSinceEpoch(json['day']);
    final activityDay = ActivityDay(activity, day);
    switch (json['type']) {
      case StartAlarm.typeName:
        return StartAlarm(activityDay);
      case EndAlarm.typeName:
        return EndAlarm(activityDay);
      case ReminderBefore.typeName:
        return ReminderBefore(activityDay,
            reminder: Duration(milliseconds: json['reminder']));
      case ReminderUnchecked.typeName:
        return ReminderUnchecked(activityDay,
            reminder: Duration(milliseconds: json['reminder']));
      default:
        throw 'unknown alarm type';
    }
  }

  ActivityAlarm setFullScreenActivity(bool fullScreenActivity) => this;

  String encode() => json.encode(toJson());

  @override
  List<Object?> get props => [activityDay.activity, activityDay.day];
}

abstract class NewAlarm extends ActivityAlarm {
  const NewAlarm(
    ActivityDay activityDay, {
    bool fullScreenActivity = false,
  }) : super(activityDay, fullScreenActivity: fullScreenActivity);

  @override
  bool hasSound(settings) => activity.alarm.sound;

  @override
  bool vibrate(settings) => activity.alarm.vibrate;

  @override
  Sound sound(AlarmSettings settings) => activity.checkable
      ? settings.checkableActivity.toSound()
      : settings.nonCheckableActivity.toSound();

  AbiliaFile get speech;
}

class StartAlarm extends NewAlarm {
  const StartAlarm(
    ActivityDay activityDay, {
    bool fullScreenActivity = false,
  }) : super(activityDay, fullScreenActivity: fullScreenActivity);

  @override
  DateTime get notificationTime => activityDay.start;

  @override
  AbiliaFile get speech => activity.extras.startTimeExtraAlarm;

  @override
  StartAlarm setFullScreenActivity(bool fullScreenActivity) =>
      StartAlarm(activityDay, fullScreenActivity: fullScreenActivity);

  @override
  String get type => typeName;
  static const String typeName = 'StartAlarm';
}

class EndAlarm extends NewAlarm {
  const EndAlarm(
    ActivityDay activityDay, {
    bool fullScreenActivity = false,
  }) : super(activityDay, fullScreenActivity: fullScreenActivity);

  @override
  DateTime get notificationTime => activityDay.end;

  @override
  AbiliaFile get speech => activity.extras.endTimeExtraAlarm;

  @override
  String get type => typeName;

  @override
  EndAlarm setFullScreenActivity(bool fullScreenActivity) =>
      EndAlarm(activityDay, fullScreenActivity: fullScreenActivity);

  static const String typeName = 'EndAlarm';
}

abstract class NewReminder extends ActivityAlarm {
  final Duration reminder;
  const NewReminder(ActivityDay activityDay, this.reminder)
      : super(activityDay);

  @override
  bool hasSound(AlarmSettings settings) =>
      settings.reminder.toSound() != Sound.NoSound;

  @override
  bool vibrate(AlarmSettings settings) => settings.vibrateAtReminder;

  @override
  Sound sound(AlarmSettings settings) => settings.reminder.toSound();

  @override
  List<Object?> get props => [reminder, ...super.props];
}

class ReminderBefore extends NewReminder {
  const ReminderBefore(ActivityDay activityDay, {required Duration reminder})
      : super(activityDay, reminder);
  @override
  DateTime get notificationTime => activityDay.start.subtract(reminder);

  @override
  String get type => typeName;
  static const String typeName = 'ReminderBefore';
}

class ReminderUnchecked extends NewReminder {
  const ReminderUnchecked(ActivityDay activityDay, {required Duration reminder})
      : super(activityDay, reminder);

  @override
  DateTime get notificationTime => activityDay.end.add(reminder);

  @override
  String get type => typeName;
  static const String typeName = 'ReminderUnchecked';
}
