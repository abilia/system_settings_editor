import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';

part 'activity_wizard_state.dart';

class ActivityWizardCubit extends Cubit<ActivityWizardState> {
  ActivityWizardCubit({
    required MemoplannerSettingsState memoplannerSettingsState,
  }) : super(ActivityWizardState(0));

  void next() {
    emit(ActivityWizardState(state.step + 1));
  }

  void previous() {
    emit(ActivityWizardState(state.step - 1));
  }
}
