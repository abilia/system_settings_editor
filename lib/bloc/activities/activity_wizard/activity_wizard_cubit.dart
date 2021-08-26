import 'package:bloc/bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

part 'activity_wizard_state.dart';

class ActivityWizardCubit extends Cubit<ActivityWizardState> {
  final EditActivityBloc editActivityBloc;
  ActivityWizardCubit({
    required MemoplannerSettingsState memoplannerSettingsState,
    required this.editActivityBloc,
  }) : super(ActivityWizardState(
          0,
          [
            if (memoplannerSettingsState.wizardDatePickerStep)
              WizardPage.DatePicker,
            WizardPage.NameAndImage,
            WizardPage.Time,
          ],
        ));

  void next() {
    final errors =
        state.currentPage().validateNextFunction()(editActivityBloc.state);
    if (errors.isEmpty) {
      emit(state.copyWith(
          newStep: (state.step + 1).clamp(0, state.pages.length - 1)));
    } else {
      emit(state.copyWith(newStep: state.step, errors: errors));
    }
  }

  void previous() {
    emit(state.copyWith(
        newStep: (state.step - 1).clamp(0, state.pages.length - 1)));
  }
}

enum WizardPage { DatePicker, NameAndImage, Time }

extension SelectedColorExtension on WizardPage {
  Set<SaveError> Function(EditActivityState eas) validateNextFunction() {
    switch (this) {
      case WizardPage.DatePicker:
        return (EditActivityState eas) => <SaveError>{};
      case WizardPage.NameAndImage:
        return (EditActivityState eas) {
          if (eas.hasTitleOrImage) {
            return <SaveError>{};
          } else {
            return {SaveError.NO_TITLE_OR_IMAGE};
          }
        };
      case WizardPage.Time:
        return (EditActivityState eas) => <SaveError>{};
    }
  }
}
