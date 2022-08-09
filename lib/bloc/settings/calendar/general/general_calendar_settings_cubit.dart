import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

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

  void changeCategorySettings(CategoriesSetting newState) =>
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
    required final bool increased,
    final Duration? morning,
    final Duration? day,
    final Duration? evening,
    final Duration? night,
  }) {
    var _morningStart = morning ?? this.morning;
    var _dayStart = day ?? this.day;
    var _eveningStart = evening ?? this.evening;
    var _nightStart = night ?? this.night;

    _morningStart = DayParts.morningLimit.clamp(_morningStart);
    _dayStart = DayParts.dayLimit.clamp(_dayStart);
    _eveningStart = DayParts.eveningLimit.clamp(_eveningStart);
    _nightStart = DayParts.nightLimit.clamp(_nightStart);

    if (increased) {
      _dayStart += _dayStart <= _morningStart ? oneHour : Duration.zero;
      _eveningStart += _eveningStart <= _dayStart ? oneHour : Duration.zero;
      _nightStart += _nightStart <= _eveningStart ? oneHour : Duration.zero;
    } else {
      _eveningStart -= _eveningStart >= _nightStart ? oneHour : Duration.zero;
      _dayStart -= _dayStart >= _eveningStart ? oneHour : Duration.zero;
      _morningStart -= _morningStart >= _dayStart ? oneHour : Duration.zero;
    }

    return DayParts(
      morning: _morningStart,
      day: _dayStart,
      evening: _eveningStart,
      night: _nightStart,
    );
  }
}
