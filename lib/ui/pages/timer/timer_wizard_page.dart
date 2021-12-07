import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/timer/timer_wizard_cubit.dart';
import 'package:seagull/ui/all.dart';

class TimerWizardPage extends StatelessWidget {
  const TimerWizardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: 0);
    return BlocListener<TimerWizardCubit, TimerWizardState>(
      listenWhen: (previous, current) =>
          current.currentStep != previous.currentStep,
      listener: (context, state) => pageController.animateToPage(state.step,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad),
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
      case TimerWizardStep.nameAndImage:
        return const TimerNameAndImageWiz();
    }
  }
}
