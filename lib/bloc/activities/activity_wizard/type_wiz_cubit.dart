import 'package:seagull/bloc/activities/activity_wizard/type_wiz_state.dart';
import 'package:seagull/bloc/all.dart';

enum CategoryType {
  right,
  left,
  fullDay,
}

class TypeWizCubit extends Cubit<TypeWizState> {
  TypeWizCubit({required CategoryType initialType})
      : super(TypeWizState(initialType));

  Future<void> updateType(CategoryType newState) async {
    emit(TypeWizState(newState));
  }
}
