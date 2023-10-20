import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class DatePickerWiz extends StatelessWidget {
  const DatePickerWiz({super.key});

  @override
  Widget build(BuildContext context) {
    final editActivityState = context.watch<EditActivityCubit>().state;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DayPickerBloc(
            clockCubit: context.read<ClockCubit>(),
            initialDay: editActivityState.timeInterval.startDate,
          ),
        ),
        BlocProvider(
          create: (context) => MonthCalendarCubit(
            clockCubit: context.read<ClockCubit>(),
            initialDay: editActivityState.timeInterval.startDate,
            dayPickerBloc: context.read<DayPickerBloc>(),
          ),
        ),
      ],
      child: BlocListener<DayPickerBloc, DayPickerState>(
        listener: (context, state) =>
            context.read<EditActivityCubit>().changeStartDate(state.day),
        child: WizardScaffold(
          title: Lt.of(context).selectDate,
          iconData: AbiliaIcons.day,
          bottom: const MonthAppBarStepper(),
          body: const MonthCalendar(),
        ),
      ),
    );
  }
}
