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
  final TextStyle? textStyle;

  static final _emptyAction = SizedBox(width: layout.actionButton.largeSize);

  static final size = Size.fromHeight(layout.appBar.largeHeight);

  const CalendarAppBar({
    required this.rows,
    required this.day,
    this.leftAction,
    this.rightAction,
    this.clockReplacement,
    this.crossedOver = false,
    this.showClock = true,
    this.calendarDayColor = DayColor.noColors,
    this.textStyle,
    Key? key,
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
                    SizedBox(
                      width: layout.appBar.clockPadding + layout.clock.width,
                    ),
                  Flexible(
                    child: CrossOver(
                      style: theme.crossOverStyle,
                      applyCross: crossedOver,
                      padding: EdgeInsets.all(
                        layout.formPadding.verticalItemDistance,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: AppBarTitle(rows: rows, style: textStyle),
                      ),
                    ),
                  ),
                  if (!clockSpaceEmpty) ...[
                    clockReplacement ?? const AbiliaClock(),
                    SizedBox(width: layout.appBar.clockPadding)
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
