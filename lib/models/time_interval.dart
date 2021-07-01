import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/utils/all.dart';

class TimeInterval extends Equatable {
  final DateTime startDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  bool get sameTime => startTime == endTime;
  bool get startTimeSet => startTime != null;
  bool get endTimeSet => endTime != null;
  bool get onlyStartTime => startTimeSet && !endTimeSet;
  bool get onlyEndTime => endTimeSet && !startTimeSet;

  DateTime get ends => startDate.withTime(endTime);
  DateTime get starts => startDate.withTime(startTime);

  const TimeInterval({this.startTime, this.endTime, required this.startDate});

  TimeInterval.fromDateTime(DateTime startDate, DateTime? endDate)
      : startTime = TimeOfDay.fromDateTime(startDate),
        endTime = endDate != null ? TimeOfDay.fromDateTime(endDate) : null,
        startDate = startDate;

  TimeInterval copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? startDate,
  }) =>
      TimeInterval(
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        startDate: startDate ?? this.startDate,
      );

  @override
  List<Object?> get props => [startTime, endTime, startDate.onlyDays()];

  @override
  String toString() => 'TimeInterval: ${yMd(startDate)} $startTime - $endTime';
}
