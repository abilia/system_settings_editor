import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';

part 'timer_wizard_state.dart';

class TimerWizardCubit extends Cubit<TimerWizardState> {
  TimerWizardCubit()
      : super(
          TimerWizardState(
            steps: UnmodifiableListView(
              [
                TimerWizardStep.duration,
                TimerWizardStep.nameAndImage,
              ],
            ),
          ),
        );

  void next() {
    if (state.isLastStep) {
      // return emit save
    }
    emit(state.copyWith(step: (state.step + 1)));
  }
}

enum TimerWizardStep {
  duration,
  nameAndImage,
}
