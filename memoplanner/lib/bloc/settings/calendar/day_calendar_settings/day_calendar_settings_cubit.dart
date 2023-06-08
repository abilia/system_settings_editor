import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class DayCalendarSettingsCubit extends Cubit<DayCalendarSettings> {
  final GenericCubit genericCubit;
  final DayCalendarViewCubit dayCalendarViewCubit;

  DayCalendarSettingsCubit({
    required DayAppBarSettings dayAppBarSettings,
    required this.dayCalendarViewCubit,
    required this.genericCubit,
  }) : super(DayCalendarSettings(
          appBar: dayAppBarSettings,
          viewOptions: dayCalendarViewCubit.state,
        ));

  void changeAppBar(DayAppBarSettings appBar) =>
      emit(DayCalendarSettings(appBar: appBar, viewOptions: state.viewOptions));

  void changeViewOptions(DayCalendarViewSettings viewSettings) => emit(
      DayCalendarSettings(appBar: state.appBar, viewOptions: viewSettings));

  Future<void> save() async {
    await genericCubit.genericUpdated(state.appBar.memoplannerSettingData);
    await dayCalendarViewCubit
        .setDayCalendarViewOptionsSettings(state.viewOptions);
  }
}

class DayCalendarSettings extends Equatable {
  final DayAppBarSettings appBar;
  final DayCalendarViewSettings viewOptions;

  const DayCalendarSettings({
    this.appBar = const DayAppBarSettings(),
    this.viewOptions = const DayCalendarViewSettings(),
  });

  @override
  List<Object> get props => [
        appBar,
        viewOptions,
      ];
}
