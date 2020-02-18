import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class NotificationPayload extends Equatable {
  final String activityId;
  final int reminder;
  final bool onStart;
  final DateTime day;

  NotificationPayload({
    @required this.activityId,
    @required this.day,
    int reminder,
    bool onStart,
  })  : this.reminder = reminder ?? -1,
        this.onStart = onStart ?? false;
  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      NotificationPayload(
        activityId: json['activityId'],
        reminder: json['reminder'],
        onStart: json['onStart'],
        day: DateTime.parse(json['day']),
      );
  Map<String, dynamic> toJson() => {
        'activityId': activityId,
        'reminder': reminder,
        'onStart': onStart,
        'day': day.toIso8601String(),
      };
  @override
  String toString() =>
      'Payload: { $activityId, reminder: $reminder, onStart: $onStart, day: $day}';
  @override
  List<Object> get props => [activityId, reminder, onStart, day];
}
