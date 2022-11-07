import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class MenuSettingsCubit extends Cubit<MenuSettings> {
  final GenericCubit genericCubit;
  MenuSettingsCubit(
    MenuSettings initial,
    this.genericCubit,
  ) : super(initial);
  void change(MenuSettings settings) => emit(settings);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
