import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TimeInterval extends Equatable {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  bool get sameTime => startTime == endTime;
  bool get startTimeSet => startTime != null;
  bool get endTimeSet => endTime != null;
  bool get onlyStartTime => startTimeSet && !endTimeSet;
  bool get onlyEndTime => endTimeSet && !startTimeSet;

  TimeInterval(this.startTime, this.endTime);

  TimeInterval.fromDateTime(DateTime startDate, DateTime endDate)
      : startTime =
            startDate != null ? TimeOfDay.fromDateTime(startDate) : null,
        endTime = endDate != null ? TimeOfDay.fromDateTime(endDate) : null;

  TimeInterval.empty()
      : startTime = null,
        endTime = null;

  @override
  List<Object> get props => [startTime, endTime];

  @override
  String toString() => 'TimeInterval: $startTime - $endTime';
}
