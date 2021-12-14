import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'general_calendar_settings_state.dart';

class GeneralCalendarSettingsCubit extends Cubit<GeneralCalendarSettingsState> {
  final GenericBloc genericBloc;

  GeneralCalendarSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericBloc,
  }) : super(GeneralCalendarSettingsState.fromMemoplannerSettings(
            settingsState));

  void changeSettings(GeneralCalendarSettingsState newState) => emit(newState);

  void changeTimepillarSettings(TimepillarSettingState newState) =>
      changeSettings(state.copyWith(timepillar: newState));

  void changeCategorySettings(CategoriesSettingState newState) =>
      changeSettings(state.copyWith(categories: newState));

  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));

  void increment(DayPart part) => _setDayPartValue(
        part,
        state.dayParts.fromDayPart(part) + Duration.millisecondsPerHour,
      );

  void decrement(DayPart part) => _setDayPartValue(
        part,
        state.dayParts.fromDayPart(part) - Duration.millisecondsPerHour,
        increased: false,
      );

  void _setDayPartValue(DayPart part, int val, {bool increased = true}) {
    DayParts dayPart;
    switch (part) {
      case DayPart.morning:
        dayPart =
            state.dayParts.copyWith(morningStart: val, increased: increased);
        break;
      case DayPart.day:
        dayPart = state.dayParts.copyWith(dayStart: val, increased: increased);
        break;
      case DayPart.evening:
        dayPart =
            state.dayParts.copyWith(eveningStart: val, increased: increased);
        break;
      case DayPart.night:
        dayPart =
            state.dayParts.copyWith(nightStart: val, increased: increased);
        break;
      default:
        return;
    }
    emit(state.copyWith(dayParts: dayPart));
  }
}

extension on DayParts {
  DayParts copyWith({
    final int? morningStart,
    final int? dayStart,
    final int? eveningStart,
    final int? nightStart,
    required final bool increased,
  }) {
    var _morningStart = morningStart ?? this.morningStart;
    var _dayStart = dayStart ?? this.dayStart;
    var _eveningStart = eveningStart ?? this.eveningStart;
    var _nightStart = nightStart ?? this.nightStart;

    _morningStart = DayParts.morningLimit.clamp(_morningStart);
    _dayStart = DayParts.dayLimit.clamp(_dayStart);
    _eveningStart = DayParts.eveningLimit.clamp(_eveningStart);
    _nightStart = DayParts.nightLimit.clamp(_nightStart);

    if (increased) {
      _dayStart +=
          _dayStart <= _morningStart ? Duration.millisecondsPerHour : 0;
      _eveningStart +=
          _eveningStart <= _dayStart ? Duration.millisecondsPerHour : 0;
      _nightStart +=
          _nightStart <= _eveningStart ? Duration.millisecondsPerHour : 0;
    } else {
      _eveningStart -=
          _eveningStart >= _nightStart ? Duration.millisecondsPerHour : 0;
      _dayStart -=
          _dayStart >= _eveningStart ? Duration.millisecondsPerHour : 0;
      _morningStart -=
          _morningStart >= _dayStart ? Duration.millisecondsPerHour : 0;
    }

    return DayParts(
      morningStart: _morningStart,
      dayStart: _dayStart,
      eveningStart: _eveningStart,
      nightStart: _nightStart,
    );
  }
}
