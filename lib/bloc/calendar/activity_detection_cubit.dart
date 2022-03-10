import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/repository/ticker.dart';

class ActivityDetectionCubit extends Cubit<ActivityDetected> {
  ActivityDetectionCubit(this.ticker) : super(ActivityDetected(ticker.time));

  final Ticker ticker;

  void activityDetected([_]) => emit(ActivityDetected(ticker.time));
}

class ActivityDetected extends Equatable {
  final DateTime timeStamp;

  const ActivityDetected(this.timeStamp);

  @override
  List<Object> get props => [timeStamp];
}
