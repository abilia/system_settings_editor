import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:seagull/models/all.dart';

abstract class NotificationAlarm extends Equatable {
  final ActivityDay activityDay;
  DateTime get day => activityDay.day;
  Activity get activity => activityDay.activity;
  bool hasSound(MemoplannerSettings settings);
  bool vibrate(MemoplannerSettings settings);
  Sound sound(MemoplannerSettings settings);
  const NotificationAlarm(this.activityDay);
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

  String encode() => json.encode(toJson());

  factory NotificationAlarm.decode(String data) =>
      NotificationAlarm.fromJson(json.decode(data));

  @override
  List<Object> get props => [activityDay];
  @override
  bool get stringify => true;
}

abstract class NewAlarm extends NotificationAlarm {
  NewAlarm(ActivityDay activityDay) : super(activityDay);

  @override
  bool hasSound(_) => activity.alarm.sound;

  @override
  bool vibrate(_) => activity.alarm.vibrate;

  @override
  Sound sound(MemoplannerSettings settings) => activity.checkable
      ? settings.checkableActivityAlarm.toSound()
      : settings.nonCheckableActivityAlarm.toSound();
}

class StartAlarm extends NewAlarm {
  StartAlarm(Activity activity, DateTime day)
      : super(ActivityDay(activity, day));
  StartAlarm.from(ActivityDay activityDay) : super(activityDay);
  @override
  DateTime get notificationTime => activityDay.start;

  @override
  String get type => typeName;
  static const String typeName = 'StartAlarm';
}

class EndAlarm extends NewAlarm {
  EndAlarm(Activity activity, DateTime day) : super(ActivityDay(activity, day));
  EndAlarm.from(ActivityDay activityDay) : super(activityDay);
  @override
  DateTime get notificationTime => activityDay.end;

  @override
  String get type => typeName;
  static const String typeName = 'EndAlarm';
}

abstract class NewReminder extends NotificationAlarm {
  final Duration reminder;
  NewReminder(ActivityDay activityDay, this.reminder) : super(activityDay);

  @override
  bool hasSound(MemoplannerSettings settings) =>
      settings.reminderAlarm.toSound() != Sound.NoSound;

  @override
  bool vibrate(MemoplannerSettings settings) => settings.vibrateAtReminder;

  @override
  Sound sound(MemoplannerSettings settings) => settings.reminderAlarm.toSound();

  @override
  List<Object> get props => [reminder, ...super.props];
}

class ReminderBefore extends NewReminder {
  ReminderBefore(Activity activity, DateTime day, {required Duration reminder})
      : super(ActivityDay(activity, day), reminder);
  ReminderBefore.from(ActivityDay activityDay, {required Duration reminder})
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
  ReminderUnchecked.from(ActivityDay activityDay, {required Duration reminder})
      : super(activityDay, reminder);
  @override
  DateTime get notificationTime => activityDay.end.add(reminder);

  @override
  String get type => typeName;
  static const String typeName = 'ReminderUnchecked';
}
