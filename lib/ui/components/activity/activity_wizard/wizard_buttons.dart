import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class WizardBottomNavigation extends StatelessWidget {
  const WizardBottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const BottomNavigation(
        backNavigationWidget: PreviousWizardStepButton(),
        forwardNavigationWidget: NextWizardStepButton(),
      );
}

class PreviousWizardStepButton extends StatelessWidget {
  const PreviousWizardStepButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      context.read<WizardCubit>().state.isFirstStep
          ? context.read<EditActivityCubit>().state is StoredActivityState ||
                  context.read<WizardCubit>() is TemplateActivityWizardCubit
              ? const CancelButton()
              : PreviousButton(
                  onPressed: () async {
                    await Navigator.of(context).maybePop();
                    context.read<WizardCubit>().previous();
                  },
                )
          : PreviousButton(onPressed: context.read<WizardCubit>().previous);
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
