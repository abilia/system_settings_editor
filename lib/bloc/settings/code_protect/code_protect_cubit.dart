import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class CodeProtectCubit extends Cubit<CodeProtectSettings> {
  final GenericCubit _genericCubit;
  CodeProtectCubit(this._genericCubit, CodeProtectSettings initial)
      : super(initial);
  void change(CodeProtectSettings newState) => emit(newState);
  void save() => _genericCubit.genericUpdated(state.memoplannerSettingData);
}
