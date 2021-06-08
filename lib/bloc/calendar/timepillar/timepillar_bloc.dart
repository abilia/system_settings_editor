// @dart=2.9

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/utils/all.dart';

part 'timepillar_event.dart';
part 'timepillar_state.dart';

class TimepillarBloc extends Bloc<TimepillarEvent, TimepillarState> {
  final ClockBloc clockBloc;
  final MemoplannerSettingBloc memoSettingsBloc;
  final DayPickerBloc dayPickerBloc;
  StreamSubscription _clockSubscription;
  StreamSubscription _memoSettingsSubscription;
  StreamSubscription _dayPickerSubscription;

  TimepillarBloc({
    @required this.clockBloc,
    @required this.memoSettingsBloc,
    @required this.dayPickerBloc,
  }) : super(TimepillarState(
          generateInterval(
              clockBloc.state, dayPickerBloc.state.day, memoSettingsBloc.state),
          memoSettingsBloc.state.timepillarZoom.zoomValue,
        )) {
    _clockSubscription = clockBloc.stream.listen((state) {
      add(TimepillarConditionsChangedEvent());
    });
    _memoSettingsSubscription = memoSettingsBloc.stream.listen((state) {
      add(TimepillarConditionsChangedEvent());
    });
    _dayPickerSubscription = dayPickerBloc.stream.listen((state) {
      add(TimepillarConditionsChangedEvent());
    });
  }

  TimepillarBloc.fake({
    this.clockBloc,
    this.memoSettingsBloc,
    this.dayPickerBloc,
    TimepillarState state,
  }) : super(state);

  @override
  Stream<TimepillarState> mapEventToState(
    TimepillarEvent event,
  ) async* {
    if (event is TimepillarConditionsChangedEvent) {
      yield TimepillarState(
        generateInterval(
            clockBloc.state, dayPickerBloc.state.day, memoSettingsBloc.state),
        memoSettingsBloc.state.timepillarZoom.zoomValue,
      );
    }
  }

  static TimepillarInterval generateInterval(
      DateTime now, DateTime day, MemoplannerSettingsState memoSettings) {
    final isToday = day.isAtSameDay(now);
    return isToday
        ? memoSettings.todayTimepillarInterval(now)
        : TimepillarInterval(
            start: day.onlyDays(),
            end: day.onlyDays().add(1.days()),
            intervalPart: IntervalPart.DAY_AND_NIGHT,
          );
  }

  @override
  Future<void> close() async {
    if (_clockSubscription != null) {
      await _clockSubscription.cancel();
    }
    if (_memoSettingsSubscription != null) {
      await _memoSettingsSubscription.cancel();
    }
    if (_dayPickerSubscription != null) {
      await _dayPickerSubscription.cancel();
    }
    return super.close();
  }
}
