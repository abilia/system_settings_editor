import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DatePickerWiz extends StatelessWidget {
  const DatePickerWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editActivityState = context.watch<EditActivityCubit>().state;
    final calendarDayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DayPickerBloc(
            clockBloc: context.read<ClockBloc>(),
            initialDay: editActivityState.timeInterval.startDate,
          ),
        ),
        BlocProvider(
          create: (context) => MonthCalendarCubit(
            clockBloc: context.read<ClockBloc>(),
            initialDay: editActivityState.timeInterval.startDate,
            dayPickerBloc: context.read<DayPickerBloc>(),
          ),
        ),
      ],
      child: BlocListener<DayPickerBloc, DayPickerState>(
        listener: (context, state) =>
            context.read<EditActivityCubit>().changeStartDate(state.day),
        child: WizardScaffold(
          title: Translator.of(context).translate.selectDate,
          iconData: AbiliaIcons.day,
          bottom: const MonthAppBarStepper(),
          body: MonthBody(
            calendarDayColor: calendarDayColor,
            showPreview: false,
          ),
        ),
      ),
    );
  }
}
