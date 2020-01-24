import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DateTime> {
  DateTime _initialState;
  final ClockBloc clockBloc;

  DayPickerBloc({@required this.clockBloc})
      : _initialState = clockBloc.initialState.onlyDays();

  @override
  DateTime get initialState => _initialState;

  @override
  Stream<DateTime> mapEventToState(DayPickerEvent event) async* {
    if (event is NextDay) {
      yield state.add(Duration(hours: 25)).onlyDays(); // For winter time
    }
    if (event is PreviousDay) {
      yield state.subtract(Duration(hours: 1)).onlyDays();
    }
    if (event is CurrentDay) yield this.clockBloc.state.onlyDays();
    if (event is GoTo) yield event.day.onlyDays();
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}
