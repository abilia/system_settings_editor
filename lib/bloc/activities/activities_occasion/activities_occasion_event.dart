import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class ActivitiesOccasionEvent extends Equatable {
  const ActivitiesOccasionEvent();
}

class NowChanged extends ActivitiesOccasionEvent {
  final DateTime now;
  NowChanged(this.now);
  @override
  List<Object> get props => [now];
  @override
  String toString() => 'NowChanged { $now }';
}

class ActivitiesChanged extends ActivitiesOccasionEvent {
  final Iterable<Activity> activities;
  final DateTime day;
  ActivitiesChanged(this.activities, this.day);
  @override
  List<Object> get props => [activities];
  @override
  String toString() => 'ActivitiesChanged { activities: $activities }';
}
