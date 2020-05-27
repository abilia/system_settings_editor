import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

@immutable
abstract class ActivitiesOccasionEvent extends Equatable {
  const ActivitiesOccasionEvent();
}

class NowChanged extends ActivitiesOccasionEvent {
  final DateTime now;
  NowChanged(this.now);
  @override
  List<Object> get props => [now];
  @override
  String toString() => 'NowChanged { ${hm(now)} }';
}

class ActivitiesChanged extends ActivitiesOccasionEvent {
  final Iterable<ActivityDay> activities;
  final DateTime day;
  ActivitiesChanged(this.activities, this.day);
  @override
  List<Object> get props => [activities];
  @override
  bool get stringify => true;
}
