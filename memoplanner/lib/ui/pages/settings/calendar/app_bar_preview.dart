import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AppBarPreview extends StatelessWidget {
  final AppBarTitleRows rows;
  final bool showBrowseButtons, showClock;
  const AppBarPreview({
    required this.showBrowseButtons,
    required this.showClock,
    required this.rows,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    final currentTime = context.watch<ClockBloc>().state;

    return FittedBox(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: CalendarAppBar.size.height,
        child: CalendarAppBar(
          leftAction: showBrowseButtons
              ? LeftNavButton(
                  onPressed: () {},
                )
              : null,
          rightAction: showBrowseButtons
              ? RightNavButton(
                  onPressed: () {},
                )
              : null,
          day: currentTime,
          calendarDayColor: dayColor,
          showClock: showClock,
          rows: rows,
        ),
      ),
    );
  }
}
