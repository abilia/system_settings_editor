import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class CalendarAppBar extends StatelessWidget {
  final Widget? leftAction;
  final Widget? rightAction;
  final Widget? clockReplacement;
  final bool showClock;
  final AppBarTitleRows rows;
  final bool crossedOver;
  final DateTime day;
  final DayColor calendarDayColor;

  static final _emptyAction = SizedBox(width: layout.actionButton.size);

  static final double clockPadding = 8.s;
  static final Size size = Size.fromHeight(layout.appBar.height);

  const CalendarAppBar({
    Key? key,
    this.leftAction,
    this.rightAction,
    this.clockReplacement,
    this.crossedOver = false,
    this.showClock = true,
    required this.rows,
    required this.day,
    this.calendarDayColor = DayColor.noColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = weekdayTheme(
      dayColor: calendarDayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    final clockToTheRight = rightAction == null && showClock;
    final clockSpaceEmpty = (clockReplacement == null && !showClock) ||
        (clockReplacement == null && clockToTheRight);
    return AnimatedTheme(
      key: TestKey.animatedTheme,
      data: theme.theme,
      child: Builder(
        builder: (context) => AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: layout.appBar.horizontalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  leftAction ?? _emptyAction,
                  if (!clockSpaceEmpty)
                    SizedBox(width: clockPadding + layout.actionButton.size),
                  Flexible(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: AppBarTitle(rows: rows),
                        ),
                        if (crossedOver)
                          CrossOver(
                            color:
                                Theme.of(context).textTheme.headline6?.color ??
                                    AbiliaColors.black,
                          ),
                      ],
                    ),
                  ),
                  if (!clockSpaceEmpty) ...[
                    clockReplacement ?? const AbiliaClock(),
                    SizedBox(width: clockPadding)
                  ],
                  rightAction ??
                      (clockToTheRight ? const AbiliaClock() : _emptyAction),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
