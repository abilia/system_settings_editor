import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DayCalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DayCalendarAppBar({Key? key}) : super(key: key);
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) =>
          BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, dayPickerState) => DayAppBar(
          day: dayPickerState.day,
          leftAction: memoSettingsState.dayCaptionShowDayButtons
              ? IconActionButton(
                  onPressed: () => BlocProvider.of<DayPickerBloc>(context)
                      .add(PreviousDay()),
                  child: const Icon(AbiliaIcons.returnToPreviousPage),
                )
              : null,
          rightAction: memoSettingsState.dayCaptionShowDayButtons
              ? IconActionButton(
                  onPressed: () =>
                      BlocProvider.of<DayPickerBloc>(context).add(NextDay()),
                  child: const Icon(AbiliaIcons.goToNextPage),
                )
              : null,
        ),
      ),
    );
  }
}
