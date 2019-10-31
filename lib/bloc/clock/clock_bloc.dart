import 'dart:async';
import 'package:bloc/bloc.dart';
//TODO This stupid.. Though it has a funny name...
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
  DateTime get initialState => DateTime.now();

  @override
  void close() {
    _tickerSubscription?.cancel();
    super.close();
  }
}
