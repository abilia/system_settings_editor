import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'general_calendar_settings_state.dart';

class GeneralCalendarSettingsCubit extends Cubit<GeneralCalendarSettingsState> {
  final GenericCubit genericCubit;

  GeneralCalendarSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericCubit,
  }) : super(GeneralCalendarSettingsState.fromMemoplannerSettings(
            settingsState));

  void changeSettings(GeneralCalendarSettingsState newState) => emit(newState);

  void changeTimepillarSettings(TimepillarSettingState newState) =>
      changeSettings(state.copyWith(timepillar: newState));

  void changeCategorySettings(CategoriesSettingState newState) =>
      changeSettings(state.copyWith(categories: newState));

  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);

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
    required final bool increased,
    final int? morningStart,
    final int? dayStart,
    final int? eveningStart,
    final int? nightStart,
  }) {
    var morningStart_ = morningStart ?? this.morningStart;
    var dayStart_ = dayStart ?? this.dayStart;
    var eveningStart_ = eveningStart ?? this.eveningStart;
    var nightStart_ = nightStart ?? this.nightStart;

    morningStart_ = DayParts.morningLimit.clamp(morningStart_);
    dayStart_ = DayParts.dayLimit.clamp(dayStart_);
    eveningStart_ = DayParts.eveningLimit.clamp(eveningStart_);
    nightStart_ = DayParts.nightLimit.clamp(nightStart_);

    if (increased) {
      dayStart_ +=
          dayStart_ <= morningStart_ ? Duration.millisecondsPerHour : 0;
      eveningStart_ +=
          eveningStart_ <= dayStart_ ? Duration.millisecondsPerHour : 0;
      nightStart_ +=
          nightStart_ <= eveningStart_ ? Duration.millisecondsPerHour : 0;
    } else {
      eveningStart_ -=
          eveningStart_ >= nightStart_ ? Duration.millisecondsPerHour : 0;
      dayStart_ -=
          dayStart_ >= eveningStart_ ? Duration.millisecondsPerHour : 0;
      morningStart_ -=
          morningStart_ >= dayStart_ ? Duration.millisecondsPerHour : 0;
    }

    return DayParts(
      morningStart: morningStart_,
      dayStart: dayStart_,
      eveningStart: eveningStart_,
      nightStart: nightStart_,
    );
  }
}
