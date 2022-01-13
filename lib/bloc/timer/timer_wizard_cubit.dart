import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:seagull/ui/all.dart';
import 'package:uuid/uuid.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

part 'timer_wizard_state.dart';

class TimerWizardCubit extends Cubit<TimerWizardState> {
  final TimerCubit timerCubit;
  final Translated translate;

  TimerWizardCubit({
    required this.timerCubit,
    required this.translate,
    BasicTimerDataItem? basicTimer,
  }) : super(
          basicTimer == null
              ? TimerWizardState(
                  steps: UnmodifiableListView(
                    [
                      TimerWizardStep.duration,
                      TimerWizardStep.start,
                    ],
                  ),
                )
              : TimerWizardState(
                  steps: UnmodifiableListView(
                    [
                      TimerWizardStep.duration,
                      TimerWizardStep.start,
                    ],
                  ),
                  duration: basicTimer.duration.milliseconds(),
                  name: basicTimer.basicTimerTitle,
                  image: basicTimer.hasImage
                      ? AbiliaFile.from(
                          id: basicTimer.fileId, path: basicTimer.icon)
                      : AbiliaFile.empty,
                  step: 1,
                  startingStep: 1,
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
    }
    emit(state.copyWith(step: (state.step + 1)));
  }

  void previous() => emit(state.copyWith(step: (state.step - 1)));

  void updateDuration(Duration duration) => emit(
        state.copyWith(
          duration: duration,
          name: state.name.isEmpty
              ? duration.toDurationString(translate, shortMin: false)
              : null,
        ),
      );

  void updateName(String text) => emit(state.copyWith(name: text));

  void updateImage(AbiliaFile file) => emit(state.copyWith(image: file));
}

enum TimerWizardStep {
  duration,
  start,
}
