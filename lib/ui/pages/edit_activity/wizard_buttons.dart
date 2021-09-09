import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class WizardBottomNavigation extends StatelessWidget {
  final Widget? nextButton;
  const WizardBottomNavigation({
    Key? key,
    this.nextButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigation(
      backNavigationWidget:
          context.read<ActivityWizardCubit>().state.isFirstStep
              ? CancelButton()
              : PreviousWizardStepButton(),
      forwardNavigationWidget:
          context.read<ActivityWizardCubit>().state.isLastStep
              ? SaveActivityButton()
              : nextButton ?? NextWizardStepButton(),
    );
  }
}

class SaveActivityButton extends StatelessWidget {
  const SaveActivityButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SaveButton(
      onPressed: () {
        context.read<EditActivityBloc>().add(SaveActivity());
      },
    );
  }
}

class PreviousWizardStepButton extends StatelessWidget {
  const PreviousWizardStepButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreviousButton(
      onPressed: () => context.read<ActivityWizardCubit>().previous(),
    );
  }
}

class NextWizardStepButton extends StatelessWidget {
  const NextWizardStepButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NextButton(
      onPressed: () {
        context.read<ActivityWizardCubit>().next();
      },
    );
  }
}
