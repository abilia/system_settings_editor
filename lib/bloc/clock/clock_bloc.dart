import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class ClockBloc extends Bloc<DateTime, DateTime> with Silent {
  StreamSubscription<DateTime>? _tickerSubscription;

  ClockBloc(Stream<DateTime> ticker, {DateTime? initialTime})
      : super((initialTime ?? DateTime.now()).onlyMinutes()) {
    _tickerSubscription = ticker.listen((tick) => add(tick));
  }

  ClockBloc.withTicker(Ticker ticker)
      : this(ticker.stream, initialTime: ticker.initialTime);

  @override
  Stream<DateTime> mapEventToState(DateTime tick) async* {
    yield tick;
  }

  @override
  Future<void> close() async {
    await _tickerSubscription?.cancel();
    return super.close();
  }

  double? minPerMin;
  void setFakeTicker({DateTime? initTime, double? ticksPerMin}) async {
    minPerMin = ticksPerMin ?? minPerMin ?? 1.0;
    await _tickerSubscription?.cancel();
    _tickerSubscription = _fake(
      initTime ?? state,
      minDuration: (1 / minPerMin! * 60000).toInt().milliseconds(),
    ).listen((tick) => add(tick));
  }

  Stream<DateTime> _fake(
    DateTime initTime, {
    Duration minDuration = const Duration(minutes: 1),
  }) async* {
    yield initTime;
    yield* Stream.periodic(
      minDuration,
      (t) => initTime.add(
        Duration(minutes: t),
      ),
    );
  }

  void resetTicker(Ticker ticker) async {
    minPerMin = null;
    await _tickerSubscription?.cancel();
    _tickerSubscription = ticker.stream.listen((tick) => add(tick));
    add(DateTime.now().onlyMinutes());
  }
}
