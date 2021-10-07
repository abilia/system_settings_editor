import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/activity/activity_wizard/checkable_wiz.dart';
import 'package:seagull/ui/components/activity/activity_wizard/remove_after_wiz.dart';

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
      case WizardStep.advance:
        return EditActivityPage();
      case WizardStep.date:
        return DatePickerWiz();
      case WizardStep.title:
        return TitleWiz();
      case WizardStep.image:
        return ImageWiz();
      case WizardStep.time:
        return TimeWiz();
      case WizardStep.connectedFunction:
        return ExtraFunctionWiz();
      case WizardStep.available_for:
        return AvailableForWiz();
      case WizardStep.checkable:
        return CheckableWiz();
      case WizardStep.type:
        return TypeWiz();
      case WizardStep.recurring:
        return RecurringWiz();
      case WizardStep.delete_after:
        return RemoveAfterWiz();
      case WizardStep.reminder:
        return RemindersWiz();
      case WizardStep.recursWeekly:
        return RecurringWeeklyWiz();
      case WizardStep.recursMonthly:
        return RecurringMonthlyWiz();
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
