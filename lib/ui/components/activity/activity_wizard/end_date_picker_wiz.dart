import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class EndDatePickerWiz extends StatelessWidget {
  const EndDatePickerWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDate =
        context.read<EditActivityBloc>().state.timeInterval.startDate;
    final activity = context.read<EditActivityBloc>().state.activity;
    final recurs = activity.recurs;
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
          title: Translator.of(context).translate.endDate,
          iconData: AbiliaIcons.day,
          bottom: const MonthAppBarStepper(),
        ),
        body: BlocListener<DayPickerBloc, DayPickerState>(
          listener: (context, state) {
            BlocProvider.of<EditActivityBloc>(context).add(
              ReplaceActivity(
                activity.copyWith(
                  recurs:
                      recurs.changeEnd(context.read<DayPickerBloc>().state.day),
                ),
              ),
            );
          },
          child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            buildWhen: (previous, current) =>
                previous.calendarDayColor != current.calendarDayColor,
            builder: (context, memoSettingsState) => MonthBody(
              calendarDayColor: memoSettingsState.calendarDayColor,
              monthCalendarType: MonthCalendarType.grid,
            ),
          ),
        ),
        bottomNavigationBar: Builder(
          builder: (context) => WizardBottomNavigation(),
        ),
      ),
    );
  }
}
