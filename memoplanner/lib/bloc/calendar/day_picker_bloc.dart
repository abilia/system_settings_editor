import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:meta/meta.dart';

part 'day_picker_event.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DayPickerState> {
  final ClockCubit clockCubit;
  late final StreamSubscription clockCubitSubscription;

  DayPickerBloc({
    required this.clockCubit,
    DateTime? initialDay,
  }) : super(
          DayPickerState(
            (initialDay ?? clockCubit.state).onlyDays(),
            clockCubit.state,
            const CurrentDay(),
          ),
        ) {
    clockCubitSubscription =
        clockCubit.stream.listen((now) => add(TimeChanged(now)));
    on<NextDay>(
        (event, emit) => emit(_generateState(state.day.nextDay(), event)));
    on<PreviousDay>(
        (event, emit) => emit(_generateState(state.day.previousDay(), event)));
    on<CurrentDay>(
        (event, emit) => emit(_generateState(clockCubit.state, event)));
    on<GoTo>((event, emit) => emit(_generateState(event.day, event)));
    on<TimeChanged>((event, emit) {
      final moveToNextDay = event.now.isMidnight() &&
          event.now.previousDay().isAtSameDay(state.day);
      emit(DayPickerState(
          moveToNextDay ? event.now : state.day, event.now, event));
    });
  }

  DayPickerState _generateState(DateTime day, DayPickerEvent lastEvent) =>
      DayPickerState(day.onlyDays(), clockCubit.state, lastEvent);

  @override
  Future<void> close() async {
    await clockCubitSubscription.cancel();
    return super.close();
  }
}

class DayPickerState {
  final DateTime day;
  final int index;
  final Occasion occasion;
  final DayPickerEvent lastEvent;
  bool get isToday => occasion == Occasion.current;

  DayPickerState(this.day, DateTime now, this.lastEvent)
      : index = day.dayIndex,
        occasion = day.isAtSameDay(now)
            ? Occasion.current
            : day.isAfter(now)
                ? Occasion.future
                : Occasion.past;

  @visibleForTesting
  DayPickerState.forTest(
    this.day,
    this.occasion, {
    this.lastEvent = const CurrentDay(),
  }) : index = day.dayIndex;

  @override
  String toString() =>
      'DayPickerState { day: ${yMd(day)}, index: $index, occasion: $occasion, lastEvent: $lastEvent }';
}
