import 'dart:async';

import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/models/all.dart';

part 'timepillar_state.dart';

class TimepillarCubit extends Cubit<TimepillarState> {
  /// All fields are null when timepillarCubit is fixed
  /// in Timepillar settings (`PreviewTimePillar`), or `TwoTimepillarCalendar`
  final ClockBloc? clockBloc;
  final MemoplannerSettingBloc? memoSettingsBloc;
  final DayPickerBloc? dayPickerBloc;
  StreamSubscription? _clockSubscription;
  StreamSubscription? _memoSettingsSubscription;
  StreamSubscription? _dayPickerSubscription;

  // ignore_for_file: prefer_initializing_formals
  TimepillarCubit({
    required ClockBloc clockBloc,
    required MemoplannerSettingBloc memoSettingsBloc,
    required DayPickerBloc dayPickerBloc,
  })  : clockBloc = clockBloc,
        memoSettingsBloc = memoSettingsBloc,
        dayPickerBloc = dayPickerBloc,
        super(TimepillarState(
          generateInterval(
              clockBloc.state, dayPickerBloc.state.day, memoSettingsBloc.state),
          memoSettingsBloc.state.timepillarZoom.zoomValue,
        )) {
    _clockSubscription = clockBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
    _memoSettingsSubscription = memoSettingsBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
    _dayPickerSubscription = dayPickerBloc.stream.listen((state) {
      _onTimepillarConditionsChanged();
    });
  }

  TimepillarCubit.fixed({
    this.clockBloc,
    this.memoSettingsBloc,
    this.dayPickerBloc,
    required TimepillarState state,
  }) : super(state);

  void _onTimepillarConditionsChanged() {
    final time = clockBloc?.state;
    final day = dayPickerBloc?.state.day;
    final settings = memoSettingsBloc?.state;
    if (time != null && day != null && settings != null) {
      emit(
        TimepillarState(
          generateInterval(time, day, settings),
          settings.timepillarZoom.zoomValue,
        ),
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
            intervalPart: IntervalPart.dayAndNight,
          );
  }

  @override
  Future<void> close() async {
    await _clockSubscription?.cancel();
    await _memoSettingsSubscription?.cancel();
    await _dayPickerSubscription?.cancel();
    return super.close();
  }
}
