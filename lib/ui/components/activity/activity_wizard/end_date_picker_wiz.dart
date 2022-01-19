import 'package:seagull/bloc/all.dart';
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
              create: (context) => MonthCalendarCubit(
                clockBloc: context.read<ClockBloc>(),
                initialDay: editActivityState.timeInterval.startDate,
              ),
            ),
            BlocProvider(
              create: (context) => DayPickerBloc(
                clockBloc: context.read<ClockBloc>(),
                initialDay: editActivityState.timeInterval.startDate,
              ),
            ),
          ],
          child: WizardScaffold(
            title: Translator.of(context).translate.endDate,
            iconData: AbiliaIcons.day,
            bottom: const MonthAppBarStepper(),
            body: BlocListener<DayPickerBloc, DayPickerState>(
              listener: (context, state) {
                BlocProvider.of<EditActivityCubit>(context).replaceActivity(
                  editActivityState.activity.copyWith(
                    recurs: editActivityState.activity.recurs
                        .changeEnd(context.read<DayPickerBloc>().state.day),
                  ),
                );
              },
              child:
                  BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
                buildWhen: (previous, current) =>
                    previous.calendarDayColor != current.calendarDayColor,
                builder: (context, memoSettingsState) => MonthBody(
                  calendarDayColor: memoSettingsState.calendarDayColor,
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
