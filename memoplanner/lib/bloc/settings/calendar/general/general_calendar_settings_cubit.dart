import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

const oneHour = Duration(hours: 1);

class GeneralCalendarSettingsCubit extends Cubit<GeneralCalendarSettings> {
  final GenericCubit genericCubit;

  GeneralCalendarSettingsCubit({
    required GeneralCalendarSettings initial,
    required this.genericCubit,
  }) : super(initial);

  void changeSettings(GeneralCalendarSettings newState) => emit(newState);

  void changeTimepillarSettings(TimepillarSettings newState) =>
      changeSettings(state.copyWith(timepillar: newState));

  void changeCategorySettings(CategoriesSettings newState) =>
      changeSettings(state.copyWith(categories: newState));

  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);

  void increment(DayPart part) => _setDayPartValue(
        part,
        state.dayParts.fromDayPart(part) + oneHour,
      );

  void decrement(DayPart part) => _setDayPartValue(
        part,
        state.dayParts.fromDayPart(part) - oneHour,
        increased: false,
      );

  void _setDayPartValue(DayPart part, Duration val, {bool increased = true}) {
    DayParts dayPart;
    switch (part) {
      case DayPart.morning:
        dayPart = state.dayParts.copyWith(morning: val, increased: increased);
        break;
      case DayPart.day:
        dayPart = state.dayParts.copyWith(day: val, increased: increased);
        break;
      case DayPart.evening:
        dayPart = state.dayParts.copyWith(evening: val, increased: increased);
        break;
      case DayPart.night:
        dayPart = state.dayParts.copyWith(night: val, increased: increased);
        break;
      default:
        return;
    }
    emit(state.copyWith(dayParts: dayPart));
  }
}

extension on DayParts {
  DayParts copyWith({
    required bool increased,
    Duration? morning,
    Duration? day,
    Duration? evening,
    Duration? night,
  }) {
    Duration newMorning = DayParts.morningLimit.clamp(morning ?? this.morning);
    Duration newDay = DayParts.dayLimit.clamp(day ?? this.day);
    Duration newEvening = DayParts.eveningLimit.clamp(evening ?? this.evening);
    Duration newNight = DayParts.nightLimit.clamp(night ?? this.night);

    if (increased) {
      newDay += newDay <= newMorning ? oneHour : Duration.zero;
      newEvening += newEvening <= newDay ? oneHour : Duration.zero;
      newNight += newNight <= newEvening ? oneHour : Duration.zero;
    } else {
      newEvening -= newEvening >= newNight ? oneHour : Duration.zero;
      newDay -= newDay >= newEvening ? oneHour : Duration.zero;
      newMorning -= newMorning >= newDay ? oneHour : Duration.zero;
    }

    return DayParts(
      morning: newMorning,
      day: newDay,
      evening: newEvening,
      night: newNight,
    );
  }
}
