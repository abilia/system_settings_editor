part of 'timepillar_bloc.dart';

abstract class TimepillarEvent {
  const TimepillarEvent();
}

class TimepillarConditionsChangedEvent extends TimepillarEvent {}
