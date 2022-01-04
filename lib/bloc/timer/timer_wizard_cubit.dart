import 'dart:collection';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:uuid/uuid.dart';

part 'timer_wizard_state.dart';

class TimerWizardCubit extends Cubit<TimerWizardState> {
  final TimerCubit timerCubit;
  final VoidCallback onBack;
  TimerWizardCubit({
    required this.timerCubit,
    required this.onBack,
  }) : super(
          TimerWizardState(
            steps: UnmodifiableListView(
              [
                TimerWizardStep.duration,
                TimerWizardStep.start,
              ],
            ),
          ),
        );

  void next() {
    if (state.isLastStep) {
      timerCubit.addTimer(
        AbiliaTimer(
          id: const Uuid().v4(),
          title: state.name,
          fileId: state.image.id,
          duration: state.duration,
          startTime: DateTime.now(),
        ),
      );
    } else {
      emit(state.copyWith(step: (state.step + 1)));
    }
  }

  void previous() {
    if (state.isFirstStep) {
      onBack();
    } else {
      emit(state.copyWith(step: (state.step - 1)));
    }
  }

  void updateDuration(Duration duration) =>
      emit(state.copyWith(duration: duration));

  void updateName(String text) => emit(state.copyWith(name: text));

  void updateImage(AbiliaFile file) => emit(state.copyWith(image: file));
}

enum TimerWizardStep {
  duration,
  start,
}
