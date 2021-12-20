import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final TimerDb timerDb;
  TimerCubit({
    required this.timerDb,
  }) : super(const TimerState(timers: []));

  Future<void> addTimer(AbiliaTimer timer) async {
    await timerDb.insert([timer]);
    emit(state.copyWith(timers: [...state.timers, timer]));
  }

  void loadTimers() async {
    final timers = await timerDb.getAllTimers();
    emit(TimerState(timers: timers));
  }
}
