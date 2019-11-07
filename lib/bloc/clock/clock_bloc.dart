import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:seagull/utils/datetime_utils.dart';
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
  DateTime get initialState => removeToMinutes(DateTime.now());

  @override
  Future<void> close() async {
    await _tickerSubscription?.cancel();
    return super.close();
  }
}
