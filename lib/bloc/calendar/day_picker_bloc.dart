// @dart=2.9

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'day_picker_event.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DayPickerState> {
  final ClockBloc clockBloc;
  StreamSubscription clockBlocSubscription;

  DayPickerBloc({
    @required this.clockBloc,
    DateTime initialDay,
    bool forDatePicking = false,
  }) : super(
          DayPickerState(
            (initialDay ?? clockBloc.state).onlyDays(),
            clockBloc.state,
            forDatePicking,
          ),
        ) {
    clockBlocSubscription =
        clockBloc.stream.listen((now) => add(TimeChanged(now)));
  }

  @override
  Stream<DayPickerState> mapEventToState(DayPickerEvent event) async* {
    if (event is NextDay) {
      yield generateState(state.day.nextDay());
    }
    if (event is PreviousDay) {
      yield generateState(state.day.previousDay());
    }
    if (event is CurrentDay) {
      yield generateState(clockBloc.state);
    }
    if (event is GoTo) {
      yield generateState(event.day);
    }
    if (event is TimeChanged) {
      yield state._timeChange(event.now);
    }
  }

  DayPickerState generateState(DateTime day) =>
      DayPickerState(day.onlyDays(), clockBloc.state, state.forDatePicking);

  @override
  Future<void> close() async {
    await clockBlocSubscription.cancel();
    return super.close();
  }
}

class DayPickerState extends Equatable {
  final DateTime day;
  final int index;
  final Occasion occasion;
  final bool forDatePicking;
  bool get isToday => occasion == Occasion.current;

  DayPickerState(this.day, DateTime now, this.forDatePicking)
      : index = day.dayIndex,
        occasion = day.isAtSameDay(now)
            ? Occasion.current
            : day.isAfter(now)
                ? Occasion.future
                : Occasion.past;

  @visibleForTesting
  DayPickerState.forTest(this.day, this.occasion)
      : forDatePicking = false,
        index = day.dayIndex;

  @override
  String toString() =>
      'DayPickerState ${forDatePicking ? 'for Date Picking ' : ''} { day: ${yMd(day)}, index: $index, occasion: $occasion }';

  @override
  List<Object> get props => [day, occasion, forDatePicking];

  DayPickerState _timeChange(DateTime now) =>
      DayPickerState(day, now, forDatePicking);
}
