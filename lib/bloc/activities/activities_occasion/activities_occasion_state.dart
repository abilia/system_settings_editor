import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

@immutable
abstract class ActivitiesOccasionState extends Equatable {
  const ActivitiesOccasionState();
  @override
  List<Object> get props => [];
}

class ActivitiesOccasionLoading extends ActivitiesOccasionState {
  ActivitiesOccasionLoading() : super();
  @override
  String toString() => 'ActivitiesOccasionLoading';
}

class ActivitiesOccasionLoaded extends ActivitiesOccasionState {
  final List<ActivityOccasion> activities;
  final List<ActivityOccasion> fullDayActivities;
  final int indexOfCurrentActivity;
  final Occasion occasion;
  final DateTime day;
  bool get isToday => occasion == Occasion.current;

  ActivitiesOccasionLoaded({
    @required this.activities,
    @required this.fullDayActivities,
    @required this.indexOfCurrentActivity,
    @required this.day,
    @required this.occasion,
  }) : super();

  @override
  List<Object> get props =>
      [activities, fullDayActivities, day, indexOfCurrentActivity, isToday];
  @override
  String toString() =>
      'ActivitiesOccasionLoaded { ${activities.length} activities, ${fullDayActivities.length} fullDay activities, day; ${yMd(day)}, ${isToday ? 'today, indexOfCurrentActivity; $indexOfCurrentActivity' : 'not today'}';
}
