import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class WizardBottomNavigation extends StatelessWidget {
  final bool useVerticalSafeArea;
  const WizardBottomNavigation({
    super.key,
    this.useVerticalSafeArea = true,
  });

  @override
  Widget build(BuildContext context) => BottomNavigation(
        useVerticalSafeArea: useVerticalSafeArea,
        backNavigationWidget: const PreviousWizardStepButton(),
        forwardNavigationWidget: const NextWizardStepButton(),
      );
}

class PreviousWizardStepButton extends StatelessWidget {
  const PreviousWizardStepButton({super.key});

  @override
  Widget build(BuildContext context) {
    final wizardCubit = context.read<WizardCubit>();
    if (wizardCubit.state.isFirstStep) {
      final editActivityState = context.read<EditActivityCubit>().state;
      final isStored = editActivityState is StoredActivityState;
      final isTemplate = wizardCubit is TemplateActivityWizardCubit;

      return isStored || isTemplate
          ? const CancelButton()
          : const PreviousButton();
    }
    return PreviousButton(onPressed: context.read<WizardCubit>().previous);
  }
}

class NextWizardStepButton extends StatelessWidget {
  const NextWizardStepButton({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocSelector<WizardCubit, WizardState, bool>(
        selector: (state) => state.isLastStep,
        builder: (context, isLastStep) => isLastStep
            ? SaveButton(onPressed: context.read<WizardCubit>().next)
            : NextButton(onPressed: context.read<WizardCubit>().next),
      );
}
