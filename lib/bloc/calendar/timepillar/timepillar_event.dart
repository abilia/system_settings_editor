// @dart=2.9

part of 'timepillar_bloc.dart';

abstract class TimepillarEvent {
  const TimepillarEvent();
}

class TimepillarConditionsChangedEvent extends TimepillarEvent with Silent {}
