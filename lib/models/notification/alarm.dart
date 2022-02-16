import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:seagull/models/all.dart';

abstract class NotificationAlarm extends Equatable {
  final ActivityDay activityDay;
  final bool fullScreenActivity;
  DateTime get day => activityDay.day;
  Activity get activity => activityDay.activity;
  String get stackId =>
      fullScreenActivity ? 'fullScreenActivity' : activityDay.activity.id;
  bool hasSound(AlarmSettings settings);
  bool vibrate(AlarmSettings settings);
  Sound sound(AlarmSettings settings);
  const NotificationAlarm(
    this.activityDay, {
    this.fullScreenActivity = false,
  });
  DateTime get notificationTime;
  String get type;

  Map<String, dynamic> toJson() => {
        'day': day.millisecondsSinceEpoch,
        'activity': activity.wrapWithDbModel().toJson(),
        'type': type,
        if (this is NewReminder)
          'reminder': (this as NewReminder).reminder.inMilliseconds,
      };
  factory NotificationAlarm.fromJson(Map<String, dynamic> json) {
    final activity = DbActivity.fromJson(json['activity']).activity;
    final day = DateTime.fromMillisecondsSinceEpoch(json['day']);
    switch (json['type']) {
      case StartAlarm.typeName:
        return StartAlarm(activity, day);
      case EndAlarm.typeName:
        return EndAlarm(activity, day);
      case ReminderBefore.typeName:
        return ReminderBefore(activity, day,
            reminder: Duration(milliseconds: json['reminder']));
      case ReminderUnchecked.typeName:
        return ReminderUnchecked(activity, day,
            reminder: Duration(milliseconds: json['reminder']));
      default:
        throw 'unknown alarm type';
    }
  }

  NotificationAlarm setFullScreenActivity(bool fullScreenActivity) => this;

  String encode() => json.encode(toJson());

  factory NotificationAlarm.decode(String data) =>
      NotificationAlarm.fromJson(json.decode(data));

  @override
  List<Object> get props => [activityDay.activity, activityDay.day];

  @override
  String toString() =>
      '$type {notificationTime: $notificationTime, ${activity.id} }';
}

abstract class NewAlarm extends NotificationAlarm {
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
  StartAlarm(Activity activity, DateTime day)
      : super(ActivityDay(activity, day));

  const StartAlarm.from(
    ActivityDay activityDay, {
    bool fullScreenActivity = false,
  }) : super(activityDay, fullScreenActivity: fullScreenActivity);

  @override
  DateTime get notificationTime => activityDay.start;

  @override
  AbiliaFile get speech => activity.extras.startTimeExtraAlarm;

  @override
  StartAlarm setFullScreenActivity(bool fullScreenActivity) =>
      StartAlarm.from(activityDay, fullScreenActivity: fullScreenActivity);

  @override
  String get type => typeName;
  static const String typeName = 'StartAlarm';
}

class EndAlarm extends NewAlarm {
  EndAlarm(Activity activity, DateTime day) : super(ActivityDay(activity, day));

  const EndAlarm.from(
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
      EndAlarm.from(activityDay, fullScreenActivity: fullScreenActivity);

  static const String typeName = 'EndAlarm';
}

abstract class NewReminder extends NotificationAlarm {
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
  List<Object> get props => [reminder, ...super.props];
}

class ReminderBefore extends NewReminder {
  ReminderBefore(Activity activity, DateTime day, {required Duration reminder})
      : super(ActivityDay(activity, day), reminder);
  const ReminderBefore.from(ActivityDay activityDay,
      {required Duration reminder})
      : super(activityDay, reminder);
  @override
  DateTime get notificationTime => activityDay.start.subtract(reminder);

  @override
  String get type => typeName;
  static const String typeName = 'ReminderBefore';
}

class ReminderUnchecked extends NewReminder {
  ReminderUnchecked(Activity activity, DateTime day,
      {required Duration reminder})
      : super(ActivityDay(activity, day), reminder);
  const ReminderUnchecked.from(ActivityDay activityDay,
      {required Duration reminder})
      : super(activityDay, reminder);
  @override
  DateTime get notificationTime => activityDay.end.add(reminder);

  @override
  String get type => typeName;
  static const String typeName = 'ReminderUnchecked';
}
