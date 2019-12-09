import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:seagull/utils.dart';

class ClockBloc extends Bloc<DateTime, DateTime> {
  StreamSubscription<DateTime> _tickerSubscription;

  final DateTime initialTime;
  ClockBloc(Stream<DateTime> ticker, {this.initialTime}) {
    _tickerSubscription = ticker.listen((tick) => add(tick));
  }

  @override
  Stream<DateTime> mapEventToState(DateTime tick) async* {
    yield tick;
  }

  @override
  DateTime get initialState => onlyMinutes(initialTime ?? DateTime.now());

  @override
  Future<void> close() async {
    await _tickerSubscription?.cancel();
    return super.close();
  }
}
