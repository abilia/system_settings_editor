import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:utils/utils.dart';

class ClockBloc extends Cubit<DateTime> {
  StreamSubscription<DateTime>? _tickerSubscription;
  Stream<DateTime> minuteStream;

  ClockBloc(this.minuteStream, {required DateTime initialTime})
      : super(initialTime.onlyMinutes()) {
    _tickerSubscription = minuteStream.listen(emit);
  }

  ClockBloc.withTicker(Ticker ticker)
      : this(ticker.minutes, initialTime: ticker.time);

  ClockBloc.fixed(DateTime initialTime)
      : this(const Stream.empty(), initialTime: initialTime);

  Future<void> setTime(DateTime time) async => emit(time.onlyMinutes());

  @override
  Future<void> close() async {
    await _tickerSubscription?.cancel();
    return super.close();
  }
}
