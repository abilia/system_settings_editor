import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'general_calendar_settings_state.dart';

class GeneralCalendarSettingsCubit extends Cubit<GeneralCalendarSettingsState> {
  final GenericBloc genericBloc;

  GeneralCalendarSettingsCubit({
    MemoplannerSettingsState settingsState,
    this.genericBloc,
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
      case DayPart.forenoon:
        dayPart =
            state.dayParts.copyWith(forenoonStart: val, increased: increased);
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
    int morningStart,
    int forenoonStart,
    int eveningStart,
    int nightStart,
    bool increased,
  }) {
    morningStart ??= this.morningStart;
    forenoonStart ??= this.forenoonStart;
    eveningStart ??= this.eveningStart;
    nightStart ??= this.nightStart;

    morningStart = DayParts.limits[DayPart.morning].clamp(morningStart);
    forenoonStart = DayParts.limits[DayPart.forenoon].clamp(forenoonStart);
    eveningStart = DayParts.limits[DayPart.evening].clamp(eveningStart);
    nightStart = DayParts.limits[DayPart.night].clamp(nightStart);

    if (increased) {
      forenoonStart +=
          forenoonStart <= morningStart ? Duration.millisecondsPerHour : 0;
      eveningStart +=
          eveningStart <= forenoonStart ? Duration.millisecondsPerHour : 0;
      nightStart +=
          nightStart <= eveningStart ? Duration.millisecondsPerHour : 0;
    } else {
      eveningStart -=
          eveningStart >= nightStart ? Duration.millisecondsPerHour : 0;
      forenoonStart -=
          forenoonStart >= eveningStart ? Duration.millisecondsPerHour : 0;
      morningStart -=
          morningStart >= forenoonStart ? Duration.millisecondsPerHour : 0;
    }

    return DayParts(
      morningStart,
      forenoonStart,
      afternoonStart,
      eveningStart,
      nightStart,
    );
  }
}
