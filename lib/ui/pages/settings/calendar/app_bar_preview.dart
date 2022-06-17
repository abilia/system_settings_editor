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
            width: layout.appBar.previewWidth,
            height: CalendarAppBar.size.height,
            child: SizedBox(
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
          ),
        ),
      ),
    );
  }
}
