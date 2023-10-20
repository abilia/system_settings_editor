import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class MenuSettingsCubit extends Cubit<MenuSettings> {
  final GenericCubit genericCubit;
  MenuSettingsCubit(
    super.initial,
    this.genericCubit,
  );
  void change(MenuSettings settings) => emit(settings);
  Future<void> save() =>
      genericCubit.genericUpdated(state.memoplannerSettingData);
}
