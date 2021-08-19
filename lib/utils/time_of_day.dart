import 'package:flutter/material.dart';

extension IntToTimeOfDay on int {
  TimeOfDay toTimeOfDay() => TimeOfDay(
        hour: this ~/ Duration.millisecondsPerHour % Duration.hoursPerDay,
        minute:
            this ~/ Duration.millisecondsPerMinute % Duration.secondsPerMinute,
      );
}
