import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class WizardBottomNavigation extends StatelessWidget {
  final FutureOr<bool?> Function()? beforeOnNext;
  final FutureOr<bool?> Function()? beforeOnPrevious;
  const WizardBottomNavigation({
    Key? key,
    this.beforeOnNext,
    this.beforeOnPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => BottomNavigation(
        backNavigationWidget: PreviousWizardStepButton(
          beforeOnPrevious: beforeOnPrevious,
        ),
        forwardNavigationWidget: NextWizardStepButton(
          beforeOnNext: beforeOnNext,
        ),
      );
}

class PreviousWizardStepButton extends StatelessWidget {
  final FutureOr<bool?> Function()? beforeOnPrevious;
  const PreviousWizardStepButton({
    Key? key,
    this.beforeOnPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      context.read<ActivityWizardCubit>().state.isFirstStep
          ? CancelButton()
          : PreviousButton(
              onPressed: () async {
                if (await beforeOnPrevious?.call() != false) {
                  context.read<ActivityWizardCubit>().previous();
                }
              },
            );
}

class NextWizardStepButton extends StatelessWidget {
  final FutureOr<bool?> Function()? beforeOnNext;
  const NextWizardStepButton({
    Key? key,
    this.beforeOnNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wizardCubit = context.read<ActivityWizardCubit>();
    void onNext() async {
      if (await beforeOnNext?.call() != false) {
        wizardCubit.next();
      }
    }

    if (wizardCubit.state.isLastStep) {
      return SaveButton(onPressed: onNext);
    }
    return NextButton(onPressed: onNext);
  }
}
