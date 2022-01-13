part of 'timer_wizard_cubit.dart';

class TimerWizardState extends Equatable {
  final Duration duration;
  final AbiliaFile image;
  final String name;
  final int step, startingStep;
  final UnmodifiableListView<TimerWizardStep> steps;

  bool get isLastStep => step == steps.length - 1;

  bool get isPastLastStep => step >= steps.length;

  bool get isBeforeFirstStep => step < 0;

  TimerWizardStep get currentStep => steps[step];

  const TimerWizardState({
    required this.steps,
    this.duration = Duration.zero,
    this.name = '',
    this.image = AbiliaFile.empty,
    this.step = 0,
    this.startingStep = 0,
  });

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
      startingStep: startingStep,
    );
  }

  @override
  List<Object?> get props => [steps, duration, name, image, step];
}
