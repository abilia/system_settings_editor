import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

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
