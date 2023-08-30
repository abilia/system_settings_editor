import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:utils/utils.dart';

class ClockCubit extends Cubit<DateTime> {
  late final StreamSubscription<DateTime> _tickerSubscription;
  final Stream<DateTime> minutesStream;

  ClockCubit(
    this.minutesStream, {
    required DateTime initialTime,
  }) : super(initialTime.onlyMinutes()) {
    _tickerSubscription = minutesStream.listen(emit);
  }

  factory ClockCubit.withTicker(Ticker ticker) =>
      ClockCubit(ticker.minutes, initialTime: ticker.time);

  factory ClockCubit.fixed(DateTime initialTime) =>
      ClockCubit(const Stream.empty(), initialTime: initialTime);

  Future<void> setTime(DateTime time) async => emit(time.onlyMinutes());

  @override
  Future<void> close() async {
    await _tickerSubscription.cancel();
    return super.close();
  }
}
