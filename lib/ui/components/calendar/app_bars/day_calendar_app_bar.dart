import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DayCalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DayCalendarAppBar({Key? key}) : super(key: key);
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState, bool>(
      selector: (state) => state.settings.dayCalendar.appBar.showBrowseButtons,
      builder: (context, dayCaptionShowDayButtons) =>
          BlocBuilder<DayPickerBloc, DayPickerState>(
        builder: (context, dayPickerState) {
          if (!dayCaptionShowDayButtons) {
            return DayAppBar(day: dayPickerState.day);
          }

          return DayAppBar(
            day: dayPickerState.day,
            leftAction: LeftNavButton(
              onPressed: BlocProvider.of<TimepillarCubit>(context).previous,
            ),
            rightAction: RightNavButton(
              onPressed: BlocProvider.of<TimepillarCubit>(context).next,
            ),
          );
        },
      ),
    );
  }
}
