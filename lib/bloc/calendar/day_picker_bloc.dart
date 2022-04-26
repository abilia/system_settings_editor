import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'day_picker_event.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DayPickerState> {
  final ClockBloc clockBloc;
  late final StreamSubscription clockBlocSubscription;

  DayPickerBloc({
    required this.clockBloc,
    DateTime? initialDay,
  }) : super(
          DayPickerState(
            (initialDay ?? clockBloc.state).onlyDays(),
            clockBloc.state,
          ),
        ) {
    clockBlocSubscription =
        clockBloc.stream.listen((now) => add(TimeChanged(now)));
    on<NextDay>(
        (event, emit) => emit(generateState(state.day.nextDay(), event)));
    on<PreviousDay>(
        (event, emit) => emit(generateState(state.day.previousDay(), event)));
    on<CurrentDay>(
        (event, emit) => emit(generateState(clockBloc.state, event)));
    on<GoTo>((event, emit) => emit(generateState(event.day, event)));
    on<TimeChanged>((event, emit) => emit(state._timeChange(event)));
  }

  DayPickerState generateState(DateTime day, DayPickerEvent lastEvent) =>
      DayPickerState(day.onlyDays(), clockBloc.state, lastEvent);

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
  final DayPickerEvent? lastDayPickerEvent;
  bool get isToday => occasion == Occasion.current;

  DayPickerState(this.day, DateTime now, [this.lastDayPickerEvent])
      : index = day.dayIndex,
        occasion = day.isAtSameDay(now)
            ? Occasion.current
            : day.isAfter(now)
                ? Occasion.future
                : Occasion.past;

  @visibleForTesting
  DayPickerState.forTest(this.day, this.occasion, [this.lastDayPickerEvent])
      : index = day.dayIndex;

  @override
  String toString() =>
      'DayPickerState { day: ${yMd(day)}, index: $index, occasion: $occasion }';

  @override
  List<Object> get props => [day, occasion];

  DayPickerState _timeChange(TimeChanged event) =>
      DayPickerState(day, event.now, event);
}
