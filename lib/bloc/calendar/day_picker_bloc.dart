import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/utils.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DateTime> {
  DateTime _initialState;
  StreamSubscription _clockSubscription;

  DayPickerBloc({@required ClockBloc clockBloc})
      : _initialState = onlyDays(clockBloc.initialState) {
    _clockSubscription = clockBloc
        .where((dt) => dt.hour == 0 && dt.minute == 0 && dt.second == 0)
        .listen((now) => _initialState = onlyDays(now));
  }

  @override
  DateTime get initialState => _initialState;

  @override
  Stream<DateTime> mapEventToState(DayPickerEvent event) async* {
    if (event is NextDay) yield onlyDays(state.add(Duration(hours: 25))); // For winter time
    if (event is PreviousDay) yield onlyDays(state.subtract(Duration(hours: 1)));
    if (event is CurrentDay) yield initialState;
    if (event is GoTo) yield onlyDays(event.day);
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    return super.close();
  }
}
