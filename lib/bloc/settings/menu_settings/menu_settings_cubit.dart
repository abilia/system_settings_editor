import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class MenuSettingsCubit extends Cubit<MenuSettings> {
  final GenericCubit genericCubit;
  MenuSettingsCubit(
    MenuSettings initial,
    this.genericCubit,
  ) : super(initial);
  void change(MenuSettings settings) => emit(settings);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
