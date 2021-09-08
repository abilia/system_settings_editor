import 'package:bloc/bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

part 'activity_wizard_state.dart';

class ActivityWizardCubit extends Cubit<ActivityWizardState> {
  final EditActivityBloc editActivityBloc;
  ActivityWizardCubit({
    required MemoplannerSettingsState memoplannerSettingsState,
    required this.editActivityBloc,
  }) : super(
          ActivityWizardState(
            0,
            [
              if (memoplannerSettingsState.wizardDatePickerStep)
                WizardStep.date,
              WizardStep.name,
              WizardStep.time,
            ],
          ),
        );

  void next() {
    final error =
        state.currentPage.validateNextFunction(editActivityBloc.state);
    if (error == null) {
      emit(state.copyWith(
          newStep: (state.step + 1).clamp(0, state.pages.length - 1)));
    } else {
      emit(state.copyWith(newStep: state.step, error: error));
    }
  }

  void previous() {
    emit(state.copyWith(
        newStep: (state.step - 1).clamp(0, state.pages.length - 1)));
  }
}

extension WizardStepExtension on WizardStep {
  SaveError? validateNextFunction(EditActivityState eas) {
    switch (this) {
      case WizardStep.name:
      case WizardStep.image:
        if (!eas.hasTitleOrImage) return SaveError.NO_TITLE_OR_IMAGE;
        break;
      case WizardStep.time:
        if (eas.hasStartTime) return SaveError.NO_START_TIME;
        break;
      default:
    }
    return null;
  }
}
