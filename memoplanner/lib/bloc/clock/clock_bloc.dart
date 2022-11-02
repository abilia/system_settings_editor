import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class ClockBloc extends Cubit<DateTime> with Finest {
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
