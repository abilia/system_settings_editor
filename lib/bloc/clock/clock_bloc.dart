import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class ClockBloc extends Cubit<DateTime> with Finest {
  StreamSubscription<DateTime>? _secondSubscription;
  Stream<DateTime> ticker;

  ClockBloc(this.ticker, {required DateTime initialTime})
      : super(initialTime.onlyMinutes()) {
    _secondSubscription = ticker
        .where((now) => state.minute != now.minute)
        .map((d) => d.onlyMinutes())
        .listen(emit);
  }

  ClockBloc.withTicker(Ticker ticker)
      : this(ticker.stream, initialTime: ticker.time);

  ClockBloc.fixed(DateTime initialTime)
      : this(const Stream.empty(), initialTime: initialTime);

  Future<void> setTime([DateTime? time]) async =>
      emit((time ?? await ticker.first).onlyMinutes());

  @override
  Future<void> close() async {
    await _secondSubscription?.cancel();
    return super.close();
  }
}
