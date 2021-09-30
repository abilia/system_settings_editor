import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
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
      case WizardStep.image:
        return NameAndImageWiz();
      case WizardStep.time:
        return TimeWiz();
      case WizardStep.advance:
        return EditActivityPage();
      default:
        return PlaceholderWiz(title: step.toString());
    }
  }
}

class DatePickerWiz extends StatelessWidget {
  const DatePickerWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDate =
        context.read<EditActivityBloc>().state.timeInterval.startDate;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MonthCalendarBloc(
            clockBloc: context.read<ClockBloc>(),
            initialDay: startDate,
          ),
        ),
        BlocProvider(
          create: (context) => DayPickerBloc(
            clockBloc: context.read<ClockBloc>(),
            initialDay: startDate,
          ),
        ),
      ],
      child: Scaffold(
        appBar: AbiliaAppBar(
          title: Translator.of(context).translate.selectDate,
          iconData: AbiliaIcons.day,
          bottom: const MonthAppBarStepper(),
        ),
        body: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          buildWhen: (previous, current) =>
              previous.calendarDayColor != current.calendarDayColor,
          builder: (context, memoSettingsState) => MonthBody(
            calendarDayColor: memoSettingsState.calendarDayColor,
            monthCalendarType: MonthCalendarType.grid,
          ),
        ),
        bottomNavigationBar: Builder(
          builder: (context) => WizardBottomNavigation(beforeOnNext: () {
            context.read<EditActivityBloc>().add(
                  ChangeDate(context.read<DayPickerBloc>().state.day),
                );
          }),
        ),
      ),
    );
  }
}

class TimeWiz extends StatelessWidget {
  const TimeWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.clock,
          title: Translator.of(context).translate.setTime,
        ),
        body: Padding(
          padding: ordinaryPadding,
          child: BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
            builder: (context, wizState) {
              return TimeIntervallPicker(
                state.timeInterval,
                startTimeError:
                    wizState.saveErrors.contains(SaveError.NO_START_TIME),
              );
            },
          ),
        ),
        bottomNavigationBar: WizardBottomNavigation(),
      ),
    );
  }
}

class NameAndImageWiz extends StatelessWidget {
  const NameAndImageWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          title: translate.enterTitleAndImage,
          iconData: AbiliaIcons.edit,
        ),
        body: Padding(
          padding: ordinaryPadding,
          child: ActivityNameAndPictureWidget(),
        ),
        bottomNavigationBar: WizardBottomNavigation(),
      ),
    );
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
