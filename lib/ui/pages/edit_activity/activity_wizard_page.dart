import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityWizardPage extends StatelessWidget {
  const ActivityWizardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: 0);
    return PopOnSaveListener(
      child: ErrorPopupListener(
        child: BlocListener<ActivityWizardCubit, ActivityWizardState>(
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
        ),
      ),
    );
  }

  Widget getPage(BuildContext context) {
    final step = context.read<ActivityWizardCubit>().state.currentStep;
    switch (step) {
      case WizardStep.basic:
        return BasicActivityStepPage();
      case WizardStep.date:
        return DatePickerWiz();
      case WizardStep.title:
        return TitleWiz();
      case WizardStep.image:
        return ImageWiz();
      case WizardStep.time:
        return TimeWiz();
      case WizardStep.advance:
        return EditActivityPage();
      default:
        return PlaceholderWiz(title: step.toString());
    }
  }
}

class PlaceholderWiz extends StatelessWidget {
  final String title;
  const PlaceholderWiz({
    Key? key,
    required this.title,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          title: title,
          iconData: AbiliaIcons.edit,
        ),
        bottomNavigationBar: WizardBottomNavigation(),
      ),
    );
  }
}