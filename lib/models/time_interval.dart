import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/utils/all.dart';

class TimeInterval extends Equatable {
  final DateTime startDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  bool get sameTime => startTime == endTime;
  bool get startTimeSet => startTime != null;
  bool get endTimeSet => endTime != null;
  bool get onlyStartTime => startTimeSet && !endTimeSet;
  bool get onlyEndTime => endTimeSet && !startTimeSet;

  const TimeInterval(this.startTime, this.endTime, this.startDate)
      : assert(startDate != null);

  TimeInterval.fromDateTime(DateTime startDate, DateTime endDate)
      : startTime =
            startDate != null ? TimeOfDay.fromDateTime(startDate) : null,
        endTime = endDate != null ? TimeOfDay.fromDateTime(endDate) : null,
        startDate = startDate;

  TimeInterval copyWith({
    TimeOfDay startTime,
    TimeOfDay endTime,
    DateTime startDate,
  }) =>
      TimeInterval(
        startTime ?? this.startTime,
        endTime ?? this.endTime,
        startDate ?? this.startDate,
      );

  @override
  List<Object> get props => [startTime, endTime, startDate.onlyDays()];

  @override
  String toString() => 'TimeInterval: ${yMd(startDate)} $startTime - $endTime';
}
