import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:utils/date_time_extensions.dart';

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

  TimeInterval({
    required this.startDate,
    this.startTime,
    this.endTime,
    DateTime? endDate,
  }) : endDate = endDate ?? noEndDate;

  const TimeInterval._({
    required this.startDate,
    this.startTime,
    this.endTime,
    this.endDate,
  });

  TimeInterval.fromDateTime(
    this.startDate,
    DateTime? endTime,
    DateTime? endDate,
  )   : startTime = TimeOfDay.fromDateTime(startDate),
        endTime = endTime != null ? TimeOfDay.fromDateTime(endTime) : null,
        endDate = endDate ?? noEndDate;

  TimeInterval copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? startDate,
  }) =>
      TimeInterval._(
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        startDate: startDate ?? this.startDate,
        endDate: endDate,
      );

  /// Convenience method to be able to set endDate to null
  TimeInterval copyWithEndDate(DateTime? endDate) => TimeInterval._(
        startTime: startTime,
        endTime: endTime,
        startDate: startDate,
        endDate: endDate,
      );

  @override
  List<Object?> get props =>
      [startTime, endTime, startDate.onlyDays(), endDate?.onlyDays()];

  @override
  bool get stringify => true;
}
