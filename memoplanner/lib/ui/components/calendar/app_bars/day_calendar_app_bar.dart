import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DayCalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DayCalendarAppBar({Key? key}) : super(key: key);
  @override
  Size get preferredSize => CalendarAppBar.size;

  @override
  Widget build(BuildContext context) {
    final showBrowseButtons = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.dayCalendar.appBar.showBrowseButtons);
    final day = context.select((DayPickerBloc bloc) => bloc.state.day);
    if (!showBrowseButtons) {
      return DayAppBar(day: day);
    }

    return DayAppBar(
      day: day,
      leftAction: LeftNavButton(
        onPressed: BlocProvider.of<TimepillarCubit>(context).previous,
      ),
      rightAction: RightNavButton(
        onPressed: BlocProvider.of<TimepillarCubit>(context).next,
      ),
    );
  }
}
