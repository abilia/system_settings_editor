part of 'activities_occasion_bloc.dart';

abstract class ActivitiesOccasionEvent extends Equatable {
  const ActivitiesOccasionEvent();
}

class NowChanged extends ActivitiesOccasionEvent {
  final DateTime now;
  const NowChanged(this.now);
  @override
  List<Object> get props => [now];
  @override
  String toString() => 'NowChanged { ${hm(now)} }';
}

class ActivitiesChanged extends ActivitiesOccasionEvent {
  final DayActivitiesLoaded dayActivitiesLoadedState;
  const ActivitiesChanged(this.dayActivitiesLoadedState);
  @override
  List<Object> get props => [dayActivitiesLoadedState];
  @override
  bool get stringify => true;
}
