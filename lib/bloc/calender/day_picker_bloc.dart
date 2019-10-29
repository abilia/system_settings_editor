import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:seagull/bloc.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DateTime> {
  @override
  DateTime get initialState => DateTime.now();

  @override
  Stream<DateTime> mapEventToState(
    DayPickerEvent event,
  ) async* {
    if (event is NextDay)
      yield state.add(Duration(days: 1));
    if (event is PreviousDay) 
      yield state.subtract(Duration(days: 1));
    if (event is CurrentDay)
      yield initialState;
    if (event is GoTo)
      yield event.day;
  }
}
