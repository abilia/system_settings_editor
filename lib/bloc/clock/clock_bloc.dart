import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class ClockBloc extends Bloc<DateTime, DateTime> with Silent {
  StreamSubscription<DateTime> _tickerSubscription;

  final DateTime initialTime;
  ClockBloc(Stream<DateTime> ticker, {this.initialTime}) {
    _tickerSubscription = ticker.listen((tick) => add(tick));
  }

  ClockBloc.withTicker(Ticker ticker)
      : this(ticker.stream, initialTime: ticker.initialTime);

  @override
  Stream<DateTime> mapEventToState(DateTime tick) async* {
    yield tick;
  }

  @override
  DateTime get initialState => (initialTime ?? DateTime.now()).onlyMinutes();

  @override
  Future<void> close() async {
    await _tickerSubscription?.cancel();
    return super.close();
  }
}
