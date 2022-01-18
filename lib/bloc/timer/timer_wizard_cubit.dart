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
  }) : super(basicTimer == null
            ? TimerWizardState.initial()
            : TimerWizardState.withBasicTimer(basicTimer));

  void next() {
    if (state.isLastStep) {
      final timer = AbiliaTimer(
        id: const Uuid().v4(),
        title: state.name,
        fileId: state.image.id,
        duration: state.duration,
        startTime: DateTime.now(),
      );
      timerCubit.addTimer(timer);
      emit(SavedTimerWizardState(state, timer));
      return;
    }
    emit(state.copyWith(
      step: (state.step + 1),
      name: state.name.isEmpty
          ? state.duration.toDurationString(translate, shortMin: false)
          : null,
    ));
  }

  void previous() => emit(state.copyWith(step: (state.step - 1)));

  void updateDuration(Duration duration) => emit(
        state.copyWith(
          duration: duration,
        ),
      );

  void updateName(String text) => emit(state.copyWith(name: text));

  void updateImage(AbiliaFile file) => emit(state.copyWith(image: file));
}

enum TimerWizardStep {
  duration,
  start,
}
