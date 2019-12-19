import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Payload extends Equatable {
  final String activityId;
  final int reminder;
  final bool onStart;

  Payload({
    @required this.activityId,
    int reminder,
    bool onStart,
  })  : this.reminder = reminder ?? -1,
        this.onStart = onStart ?? false;
  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        activityId: json['activityId'],
        reminder: json['reminder'],
        onStart: json['onStart'],
      );
  Map<String, dynamic> toJson() => {
        'activityId': activityId,
        'reminder': reminder,
        'onStart': onStart,
      };
  @override
  String toString() =>
      'Payload: { $activityId, reminder: $reminder, onStart: $onStart}';
  @override
  List<Object> get props => [activityId, reminder, onStart];
}
