import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class MenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MenuAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(layout.appBar.largeHeight);

  @override
  Widget build(BuildContext context) {
    final calendarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.calendar);
    final appBarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.dayAppBar);
    final time = context.watch<ClockCubit>().state;

    return CalendarAppBar(
      day: time,
      calendarDayColor: calendarSettings.dayColor,
      rows: AppBarTitleRows.day(
        settings: appBarSettings,
        currentTime: time,
        day: time,
        dayPart: context.read<DayPartCubit>().state,
        dayParts: calendarSettings.dayParts,
        langCode: Localizations.localeOf(context).toLanguageTag(),
        translate: Lt.of(context),
      ),
      showClock: appBarSettings.showClock,
    );
  }
}
