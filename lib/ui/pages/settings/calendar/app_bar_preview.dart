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
        builder: (context, currentTime) => FittedBox(
          child: SizedBox(
            width: 375.s,
            height: CalendarAppBar.size.height,
            child: SizedBox(
              height: CalendarAppBar.size.height,
              child: CalendarAppBar(
                leftAction: showBrowseButtons
                    ? ActionButton(
                        onPressed: () {},
                        child: const Icon(AbiliaIcons.returnToPreviousPage),
                      )
                    : null,
                rightAction: showBrowseButtons
                    ? ActionButton(
                        onPressed: () {},
                        child: const Icon(AbiliaIcons.goToNextPage),
                      )
                    : null,
                day: currentTime,
                calendarDayColor: memoSettingsState.calendarDayColor,
                showClock: showClock,
                rows: rows,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
