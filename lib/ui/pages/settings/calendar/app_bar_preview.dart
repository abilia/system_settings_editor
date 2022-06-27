import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class AppBarPreview extends StatelessWidget {
  final AppBarTitleRows rows;
  final bool showBrowseButtons, showClock;
  const AppBarPreview({
    Key? key,
    required this.showBrowseButtons,
    required this.showClock,
    required this.rows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, currentTime) {
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
                calendarDayColor: memoSettingsState.calendarDayColor,
                showClock: showClock,
                rows: rows,
              ),
            ),
          );
        },
      ),
    );
  }
}
