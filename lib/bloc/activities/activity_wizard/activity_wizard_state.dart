part of 'activity_wizard_cubit.dart';

class ActivityWizardState extends Equatable {
  final int step;
  const ActivityWizardState(this.step);

  @override
  List<Object> get props => [step];
}

class WizardStep {}
