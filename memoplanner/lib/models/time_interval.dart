import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memoplanner/utils/all.dart';

class TimeInterval extends Equatable {
  final DateTime startDate;
  final DateTime? endDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  bool get sameTime => startTime == endTime;

  bool get startTimeSet => startTime != null;

  bool get endTimeSet => endTime != null;

  bool get onlyStartTime => startTimeSet && !endTimeSet;

  bool get onlyEndTime => endTimeSet && !startTimeSet;

  DateTime get ends => startDate.withTime(endTime);

  DateTime get starts => startDate.withTime(startTime);

  const TimeInterval({
    required this.startDate,
    this.startTime,
    this.endTime,
    this.endDate,
  });

  TimeInterval.fromDateTime(this.startDate, DateTime? endTime, this.endDate)
      : startTime = TimeOfDay.fromDateTime(startDate),
        endTime = endTime != null ? TimeOfDay.fromDateTime(endTime) : null;

  TimeInterval copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      TimeInterval(
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );

  /// Convenience method to be able to set endDate to null
  TimeInterval changeEndDate(DateTime? endDate) => TimeInterval(
      startTime: startTime,
      endTime: endTime,
      startDate: startDate,
      endDate: endDate);

  @override
  List<Object?> get props =>
      [startTime, endTime, startDate.onlyDays(), endDate?.onlyDays()];

  @override
  bool get stringify => true;
}
