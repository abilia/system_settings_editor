import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class WizardBottomNavigation extends StatelessWidget {
  final bool useVerticalSafeArea;

  const WizardBottomNavigation({
    Key? key,
    this.useVerticalSafeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BottomNavigation(
        useVerticalSafeArea: useVerticalSafeArea,
        backNavigationWidget: const PreviousWizardStepButton(),
        forwardNavigationWidget: const NextWizardStepButton(),
      );
}

class PreviousWizardStepButton extends StatelessWidget {
  const PreviousWizardStepButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.read<WizardCubit>().state.isFirstStep) {
      final isStored =
          context.read<EditActivityCubit>().state is StoredActivityState;
      final isTemplate =
          context.read<WizardCubit>() is TemplateActivityWizardCubit;

      return PopOrDiscardButton(
        unchangedCondition: (context) =>
            context.read<EditActivityCubit>().state.unchanged,
        type: isStored || isTemplate ? ButtonType.cancel : ButtonType.previous,
      );
    }
    return PreviousButton(onPressed: context.read<WizardCubit>().previous);
  }
}

class NextWizardStepButton extends StatelessWidget {
  const NextWizardStepButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocSelector<WizardCubit, WizardState, bool>(
        selector: (state) => state.isLastStep,
        builder: (context, isLastStep) => isLastStep
            ? SaveButton(onPressed: context.read<WizardCubit>().next)
            : NextButton(onPressed: context.read<WizardCubit>().next),
      );
}
