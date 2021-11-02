import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class CodeProtectCubit extends Cubit<CodeProtectSettings> {
  final GenericBloc _genericBloc;
  CodeProtectCubit(this._genericBloc, CodeProtectSettings initial)
      : super(initial);
  void change(CodeProtectSettings newState) => emit(newState);
  void save() => _genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
