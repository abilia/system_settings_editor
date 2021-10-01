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
              ? ActionButton(
                  onPressed: () => BlocProvider.of<DayPickerBloc>(context)
                      .add(PreviousDay()),
                  child: Icon(AbiliaIcons.return_to_previous_page),
                )
              : null,
          rightAction: memoSettingsState.dayCaptionShowDayButtons
              ? ActionButton(
                  onPressed: () =>
                      BlocProvider.of<DayPickerBloc>(context).add(NextDay()),
                  child: Icon(AbiliaIcons.go_to_next_page),
                )
              : null,
        ),
      ),
    );
  }
}
