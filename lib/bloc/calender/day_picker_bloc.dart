import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DateTime> {

  DateTime _initialState;
  StreamSubscription _clockSubscription;

  DayPickerBloc({@required ClockBloc clockBloc}) : _initialState = clockBloc.initialState {
    _clockSubscription = clockBloc
        .where((dt) => dt.hour == 0 && dt.minute == 0)
        .listen((now) => _initialState = now);
  }

  @override
  DateTime get initialState => _initialState;

  @override
  Stream<DateTime> mapEventToState(DayPickerEvent event) async* {
    if (event is NextDay) yield state.add(Duration(days: 1));
    if (event is PreviousDay) yield state.subtract(Duration(days: 1));
    if (event is CurrentDay) yield initialState;
    if (event is GoTo) yield event.day;
  }

    @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    return super.close();
  }
}
