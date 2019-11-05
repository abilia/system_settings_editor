import 'dart:async';
import 'package:bloc/bloc.dart';
class ClockBloc extends Bloc<DateTime, DateTime> {
  StreamSubscription<DateTime> _tickerSubscription;

  ClockBloc(Stream<DateTime> ticker) {
    _tickerSubscription = ticker.listen((tick) => add(tick));
  }

  @override
  Stream<DateTime> mapEventToState(DateTime tick) async* {
    yield tick;
  }

  @override
  DateTime get initialState {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);
  }

  @override
  void close() {
    _tickerSubscription?.cancel();
    super.close();
  }
}
