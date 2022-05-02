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
            false,
          ),
        ) {
    clockBlocSubscription =
        clockBloc.stream.listen((now) => add(TimeChanged(now)));
    on<NextDay>(
        (event, emit) => emit(generateState(state.day.nextDay(), true)));
    on<PreviousDay>(
        (event, emit) => emit(generateState(state.day.previousDay(), true)));
    on<CurrentDay>(
        (event, emit) => emit(generateState(clockBloc.state, false)));
    on<GoTo>((event, emit) => emit(generateState(event.day, false)));
    on<TimeChanged>(
        (event, emit) => emit(DayPickerState(state.day, event.now, false)));
  }

  DayPickerState generateState(DateTime day, bool stepEvent) =>
      DayPickerState(day.onlyDays(), clockBloc.state, stepEvent);

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
  final bool lastEventStepEvent;
  bool get isToday => occasion == Occasion.current;

  DayPickerState(this.day, DateTime now, this.lastEventStepEvent)
      : index = day.dayIndex,
        occasion = day.isAtSameDay(now)
            ? Occasion.current
            : day.isAfter(now)
                ? Occasion.future
                : Occasion.past;

  @visibleForTesting
  DayPickerState.forTest(this.day, this.occasion,
      {this.lastEventStepEvent = false})
      : index = day.dayIndex;

  @override
  String toString() =>
      'DayPickerState { day: ${yMd(day)}, index: $index, occasion: $occasion }';

  @override
  List<Object> get props => [day, occasion];
}
