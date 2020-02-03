import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DayPickerState> {
  DayPickerState _initialState;
  static final int startIndex = 1000000;
  final ClockBloc clockBloc;

  DayPickerBloc({@required this.clockBloc})
      : _initialState =
            DayPickerState(clockBloc.initialState.onlyDays(), startIndex);

  @override
  DayPickerState get initialState => _initialState;

  @override
  Stream<DayPickerState> mapEventToState(DayPickerEvent event) async* {
    if (event is NextDay) {
      yield generateState(
          state.day.add(Duration(hours: 25)).onlyDays()); // For winter time
    }
    if (event is PreviousDay) {
      yield generateState(state.day.subtract(Duration(hours: 1)).onlyDays());
    }
    if (event is CurrentDay) {
      yield generateState(this.clockBloc.state.onlyDays());
    }
    if (event is GoTo) {
      yield generateState(event.day.onlyDays());
    }
  }

  DayPickerState generateState(DateTime day) {
    final dayDiff = day.difference(_initialState.day).inDays;
    final index = startIndex + dayDiff;
    return DayPickerState(day, index);
  }

  DateTime indexToDate(int index) {
    final indexDiff = startIndex - index;
    return _initialState.day.add(Duration(days: indexDiff));
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}

class DayPickerState extends Equatable {
  final DateTime day;
  final int index;

  DayPickerState(this.day, this.index);

  @override
  String toString() => 'DayPickerState { day: $day, index: $index }';

  @override
  List<Object> get props => [day, index];
}
