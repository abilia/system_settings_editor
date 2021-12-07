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
    on<NextDay>((event, emit) => emit(generateState(state.day.nextDay())));
    on<PreviousDay>(
        (event, emit) => emit(generateState(state.day.previousDay())));
    on<CurrentDay>((event, emit) => emit(generateState(clockBloc.state)));
    on<GoTo>((event, emit) => emit(generateState(event.day)));
    on<TimeChanged>((event, emit) => emit(state._timeChange(event.now)));
  }

  DayPickerState generateState(DateTime day) =>
      DayPickerState(day.onlyDays(), clockBloc.state);

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
  bool get isToday => occasion == Occasion.current;

  DayPickerState(this.day, DateTime now)
      : index = day.dayIndex,
        occasion = day.isAtSameDay(now)
            ? Occasion.current
            : day.isAfter(now)
                ? Occasion.future
                : Occasion.past;

  @visibleForTesting
  DayPickerState.forTest(this.day, this.occasion) : index = day.dayIndex;

  @override
  String toString() =>
      'DayPickerState { day: ${yMd(day)}, index: $index, occasion: $occasion }';

  @override
  List<Object> get props => [day, occasion];

  DayPickerState _timeChange(DateTime now) => DayPickerState(day, now);
}
