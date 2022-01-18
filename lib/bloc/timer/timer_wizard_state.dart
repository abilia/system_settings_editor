part of 'timer_wizard_cubit.dart';

class TimerWizardState extends Equatable {
  final Duration duration;
  final AbiliaFile image;
  final String name;
  final int step;
  final UnmodifiableListView<TimerWizardStep> steps;

  bool get isLastStep => step == steps.length - 1;

  bool get isPastLastStep => step >= steps.length;

  bool get isBeforeFirstStep => step < 0;

  TimerWizardStep get currentStep => steps[step];

  static final _defaultSteps = UnmodifiableListView(
    [
      TimerWizardStep.duration,
      TimerWizardStep.start,
    ],
  );

  const TimerWizardState({
    required this.steps,
    this.duration = Duration.zero,
    this.name = '',
    this.image = AbiliaFile.empty,
    this.step = 0,
  });

  factory TimerWizardState.initial() {
    return TimerWizardState(steps: _defaultSteps);
  }

  factory TimerWizardState.withBasicTimer(BasicTimerDataItem basicTimer) {
    return TimerWizardState(
      steps: _defaultSteps,
      duration: basicTimer.duration.milliseconds(),
      name: basicTimer.basicTimerTitle,
      image: basicTimer.hasImage()
          ? AbiliaFile.from(id: basicTimer.fileId, path: basicTimer.icon)
          : AbiliaFile.empty,
      step: 1,
    );
  }

  TimerWizardState copyWith({
    Duration? duration,
    String? name,
    AbiliaFile? image,
    int? step,
    DateTime? startTime,
  }) {
    return TimerWizardState(
      steps: steps,
      duration: duration ?? this.duration,
      name: name ?? this.name,
      image: image ?? this.image,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [steps, duration, name, image, step];
}

class SavedTimerWizardState extends TimerWizardState {
  final AbiliaTimer savedTimer;
  SavedTimerWizardState(TimerWizardState state, this.savedTimer)
      : super(
          steps: state.steps,
          duration: state.duration,
          name: state.name,
          image: state.image,
          step: state.step,
        );

  @override
  List<Object?> get props => [savedTimer];
}
