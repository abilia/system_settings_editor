import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityWizardPage extends StatelessWidget {
  ActivityWizardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: 0);
    return BlocProvider<EditActivityBloc>(
      create: (_) => EditActivityBloc.newActivity(
        activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
        clockBloc: BlocProvider.of<ClockBloc>(context),
        memoplannerSettingBloc:
            BlocProvider.of<MemoplannerSettingBloc>(context),
        day: context.read<DayPickerBloc>().state.day,
      ),
      child: BlocProvider(
        create: (context) => ActivityWizardCubit(
          memoplannerSettingsState:
              context.read<MemoplannerSettingBloc>().state,
          editActivityBloc: context.read<EditActivityBloc>(),
        ),
        child: EditActivityListeners(
          scroll: false,
          child: BlocListener<ActivityWizardCubit, ActivityWizardState>(
            listener: (context, state) {
              final error = state.currentError;
              if (error == null) {
                pageController.animateToPage(state.step,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuad);
              } else {
                showViewDialog(
                  context: context,
                  builder: (context) => ErrorDialog(
                      text: error.toMessage(Translator.of(context).translate)),
                );
              }
            },
            child: PageView.builder(
                controller: pageController,
                itemBuilder: (context, index) => getPage(
                    context.read<ActivityWizardCubit>().state.currentPage)),
          ),
        ),
      ),
    );
  }

  Widget getPage(WizardStep p) {
    switch (p) {
      case WizardStep.date:
        return DatePickerWiz();
      case WizardStep.name:
      case WizardStep.image:
        return NameAndImageWiz();
      case WizardStep.time:
        return TimeWiz();
      default:
        throw 'not implemented yet';
    }
  }
}

class DatePickerWiz extends StatelessWidget {
  const DatePickerWiz();

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
          builder: (context) => WizardBottomNavigation(
            nextButton: NextButton(
              onPressed: () {
                context
                    .read<EditActivityBloc>()
                    .add(ChangeDate(context.read<DayPickerBloc>().state.day));
                context.read<ActivityWizardCubit>().next();
              },
            ),
          ),
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
          child: TimeIntervallPicker(state.timeInterval),
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
          child: ActivityNameAndPictureWidget(state),
        ),
        bottomNavigationBar: WizardBottomNavigation(),
      ),
    );
  }
}

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
