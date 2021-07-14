part of 'activities_occasion_bloc.dart';

abstract class ActivitiesOccasionState extends Equatable {
  const ActivitiesOccasionState();
  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

class ActivitiesOccasionLoading extends ActivitiesOccasionState {
  ActivitiesOccasionLoading() : super();
}

class ActivitiesOccasionLoaded extends ActivitiesOccasionState {
  final List<ActivityOccasion> activities;
  final List<ActivityOccasion> pastActivities;
  final List<ActivityOccasion> notPastActivities;
  final List<ActivityOccasion> fullDayActivities;
  final Occasion occasion;
  final DateTime day;
  bool get isToday => occasion == Occasion.current;

  ActivitiesOccasionLoaded({
    required this.activities,
    required this.fullDayActivities,
    required this.day,
    required this.occasion,
  })  : pastActivities = activities.where((ao) => ao.isPast).toList(),
        notPastActivities = activities.where((ao) => !ao.isPast).toList(),
        super();

  @override
  List<Object> get props => [
        occasion,
        activities,
        fullDayActivities,
        day,
        isToday,
      ];

  @override
  bool get stringify => true;
}
