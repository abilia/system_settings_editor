import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/ui/all.dart';

class ActivityWizardPage extends StatelessWidget {
  const ActivityWizardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: 0);
    return PopAwareDiscardListener(
      discardDialogCondition: (context) =>
          !context.read<EditActivityCubit>().state.unchanged,
      child: PopOnSaveListener(
        child: ErrorPopupListener(
          child: BlocListener<WizardCubit, WizardState>(
            listenWhen: (previous, current) =>
                current.currentStep != previous.currentStep,
            listener: (context, state) => pageController.animateToPage(
                state.step,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutQuad),
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              itemBuilder: (context, _) => getPage(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget getPage(BuildContext context) {
    final step = context.read<WizardCubit>().state.currentStep;
    switch (step) {
      case WizardStep.advance:
        return const EditActivityPage();
      case WizardStep.date:
        return const DatePickerWiz();
      case WizardStep.title:
        return const TitleWiz();
      case WizardStep.image:
        return const ImageWiz();
      case WizardStep.time:
        return const TimeWiz();
      case WizardStep.connectedFunction:
        return const ExtraFunctionWiz();
      case WizardStep.availableFor:
        return const AvailableForWiz();
      case WizardStep.checkable:
        return const CheckableWiz();
      case WizardStep.fullDay:
        return const FullDayWiz();
      case WizardStep.category:
        return const CategoryWiz();
      case WizardStep.recurring:
        return const RecurringWiz();
      case WizardStep.deleteAfter:
        return const RemoveAfterWiz();
      case WizardStep.alarm:
        return const AlarmWiz();
      case WizardStep.reminder:
        return const RemindersWiz();
      case WizardStep.recursWeekly:
        return const RecurringWeeklyWiz();
      case WizardStep.recursMonthly:
        return const RecurringMonthlyWiz();
      case WizardStep.endDate:
        return const EndDatePickerWiz();
    }
  }
}
