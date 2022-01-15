import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimerWizardPage extends StatelessWidget {
  const TimerWizardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startingStep = context.read<TimerWizardCubit>().state.step;
    final pageController = PageController(initialPage: startingStep);
    return BlocListener<TimerWizardCubit, TimerWizardState>(
      listenWhen: (previous, current) => current.step != previous.step,
      listener: (context, state) {
        if (state.isPastLastStep) {
          return Navigator.pop(context, true);
        }
        if (state.isBeforeFirstStep) {
          return Navigator.pop(context, false);
        }
        pageController.animateToPage(state.step,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad);
      },
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        itemBuilder: (context, _) => getPage(context),
      ),
    );
  }

  Widget getPage(BuildContext context) {
    final step = context.read<TimerWizardCubit>().state.currentStep;
    switch (step) {
      case TimerWizardStep.duration:
        return const TimerDurationWiz();
      case TimerWizardStep.start:
        return const TimerStartWiz();
    }
  }
}
