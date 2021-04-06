import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'day_picker_event.dart';

class DayPickerBloc extends Bloc<DayPickerEvent, DayPickerState> {
  final DateTime _initialDay;
  static final int startIndex = 1000000;
  final ClockBloc clockBloc;
  StreamSubscription clockBlocSubscription;

  DayPickerBloc({@required this.clockBloc})
      : _initialDay = clockBloc.state.onlyDays(),
        super(DayPickerState(
            clockBloc.state.onlyDays(), startIndex, clockBloc.state)) {
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

  DayPickerState generateState(DateTime day) {
    day = day.onlyDays();
    // DateTime.days does not work for daylight saving
    final dayDiff = (day.difference(_initialDay).inHours / 24).round();
    return DayPickerState(day, startIndex + dayDiff, clockBloc.state);
  }

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

  DayPickerState(this.day, this.index, DateTime now)
      : occasion = day.isAtSameDay(now)
            ? Occasion.current
            : day.isAfter(now)
                ? Occasion.future
                : Occasion.past;

  @visibleForTesting
  DayPickerState.forTest(this.day, this.index, this.occasion);

  @override
  String toString() =>
      'DayPickerState { day: ${yMd(day)}, index: $index, occasion: $occasion }';

  @override
  List<Object> get props => [day, index, occasion];

  DayPickerState _timeChange(DateTime now) => DayPickerState(day, index, now);
}
