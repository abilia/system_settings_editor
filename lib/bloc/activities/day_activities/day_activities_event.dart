import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

@immutable
abstract class DayActivitiesEvent extends Equatable {
  const DayActivitiesEvent();
}

class UpdateDay extends DayActivitiesEvent {
  final DateTime dayFilter;

  const UpdateDay(this.dayFilter);

  @override
  List<Object> get props => [dayFilter];

  @override
  String toString() => 'UpdateDay { ${[
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][dayFilter.weekday - 1]}, ${yMd(dayFilter)} }';
}

class UpdateActivities extends DayActivitiesEvent {
  final Iterable<Activity> activities;

  const UpdateActivities(this.activities);

  @override
  List<Object> get props => [activities];

  @override
  String toString() => 'UpdateActivities { ${activities.length} activities }';
}
