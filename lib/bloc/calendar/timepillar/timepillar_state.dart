part of 'timepillar_bloc.dart';

class TimepillarState extends Equatable {
  final TimepillarInterval timepillarInterval;

  const TimepillarState(this.timepillarInterval);

  @override
  List<Object> get props => [timepillarInterval];
}

