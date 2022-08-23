import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/all.dart';
import 'package:seagull/ui/all.dart';

class EndDatePickerWiz extends StatelessWidget {
  const EndDatePickerWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, editActivityState) {
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
          child: WizardScaffold(
            title: Translator.of(context).translate.endDate,
            iconData: AbiliaIcons.day,
            bottom: const MonthAppBarStepper(),
            body: BlocListener<DayPickerBloc, DayPickerState>(
              listener: (context, state) {
                BlocProvider.of<EditActivityCubit>(context).newRecurrence(
                    newEndDate: context.read<DayPickerBloc>().state.day);
                // changeTimeInterval(
                //     endDate: context.read<DayPickerBloc>().state.day);
              },
              child: BlocSelector<MemoplannerSettingBloc,
                  MemoplannerSettingsState, DayColor>(
                selector: (state) => state.settings.calendar.dayColor,
                builder: (context, calendarDayColor) => MonthBody(
                  calendarDayColor: calendarDayColor,
                  showPreview: false,
                ),
              ),
            ),
            bottomNavigationBar: Builder(
              builder: (context) => const WizardBottomNavigation(),
            ),
          ),
        );
      },
    );
  }
}
