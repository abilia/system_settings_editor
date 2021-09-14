import 'package:bloc/bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'activity_wizard_state.dart';

class ActivityWizardCubit extends Cubit<ActivityWizardState> {
  ActivityWizardCubit({
    MemoplannerSettingsState? settings,
  }) : super(
          ActivityWizardState(
            0,
            settings != null
                ? settings.addActivityType == NewActivityMode.stepByStep
                    ? [
                        if (settings.wizardTemplateStep) WizardStep.basic,
                        if (settings.wizardDatePickerStep) WizardStep.date,
                        WizardStep.title,
                        if (settings.wizardImageStep) WizardStep.time,
                      ]
                    : [
                        if (settings.advancedActivityTemplate) WizardStep.basic,
                        WizardStep.advance,
                      ]
                : [],
          ),
        );

  void next() => emit(state.copyWith(newStep: (state.step + 1)));

  void previous() => emit(state.copyWith(newStep: (state.step - 1)));
}
