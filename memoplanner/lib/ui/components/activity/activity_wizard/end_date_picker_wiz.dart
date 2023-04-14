import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class EndDatePickerWiz extends StatelessWidget {
  const EndDatePickerWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DayPickerBloc(
            clockBloc: context.read<ClockBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => MonthCalendarCubit(
            clockBloc: context.read<ClockBloc>(),
            dayPickerBloc: context.read<DayPickerBloc>(),
          ),
        ),
      ],
      child: WizardScaffold(
        title: Translator.of(context).translate.endDate,
        iconData: AbiliaIcons.day,
        bottom: const MonthAppBarStepper(),
        body: BlocListener<DayPickerBloc, DayPickerState>(
          listener: (context, state) {
            BlocProvider.of<EditActivityCubit>(context).changeRecurrentEndDate(
              context.read<DayPickerBloc>().state.day,
            );
          },
          child: const MonthCalendar(),
        ),
        bottomNavigationBar: Builder(
          builder: (context) => const WizardBottomNavigation(),
        ),
      ),
    );
  }
}
