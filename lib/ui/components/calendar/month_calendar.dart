import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import 'package:seagull/ui/all.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MonthAppBar(),
      body: Column(
        children: [
          const MonthHeading(),
          const Expanded(
            child: MonthContent(),
          ),
        ],
      ),
    );
  }
}

class MonthContent extends StatelessWidget {
  const MonthContent({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarBloc, MonthCalendarState>(
      builder: (context, state) {
        return Column(
          children: state.weeks
              .map(
                (week) => Expanded(
                  child: WeekRow(week),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class WeekRow extends StatelessWidget {
  final MonthWeek week;
  const WeekRow(this.week, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.s),
      child: Row(
        children: [
          WeekNumber(weekNumber: week.number),
          ...week.days
              .map((day) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.s),
                          child: MonthDayView(day),
                        ),
                      ) // MonthDay(day + 1),
                  )
              .toList(),
        ],
      ),
    );
  }
}

class MonthHeading extends StatelessWidget {
  const MonthHeading({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateformat = DateFormat('', '${Localizations.localeOf(context)}');
    final weekdays = dateformat.dateSymbols.STANDALONEWEEKDAYS;
    final weekdaysShort = dateformat.dateSymbols.STANDALONESHORTWEEKDAYS;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const WeekNumber(),
        ...List.generate(DateTime.daysPerWeek, (weekday) {
          final weekdayindex = (weekday + 1) % DateTime.daysPerWeek;
          return Expanded(
            child: Tts(
              data: weekdays[weekdayindex],
              child: Text(
                weekdaysShort[weekdayindex],
                textAlign: TextAlign.center,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class MonthDayView extends StatelessWidget {
  final MonthCalendarDay monthDay;
  const MonthDayView(
    this.monthDay, {
    Key key,
  }) : super(key: key);
  static final radius = Radius.circular(8.s);

  @override
  Widget build(BuildContext context) {
    final day = monthDay;
    if (day is MonthDay) {
      return Container(
        foregroundDecoration: day.isCurrent
            ? BoxDecoration(
                border: currentActivityBorder,
                borderRadius: BorderRadius.all(radius),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AbiliaColors.black80,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                ),
              ),
              height: 24.s,
              padding: EdgeInsets.symmetric(horizontal: 4.s),
              child: DefaultTextStyle(
                style: abiliaTextTheme.subtitle2.copyWith(
                  color: AbiliaColors.white,
                ),
                child: Row(
                  children: [
                    Text('${day.day}'),
                    Spacer(),
                    if (day.hasActivities) ColorDot(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: radius, bottomRight: radius),
                    border: day.occasion == Occasion.current
                        ? null
                        : border //noTopborder
                    ),
                padding: EdgeInsets.fromLTRB(4.s, 6.s, 4.s, 8.s),
                child: Stack(
                  children: [
                    if (day.fullDayActivityCount > 1)
                      Container(
                        color: AbiliaColors.white,
                      )
                    else if (day.fullDayActivity != null)
                      Container(
                        color: AbiliaColors.green,
                      ),
                    if (day.occasion == Occasion.past) CrossOver(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }
}

class WeekNumber extends StatelessWidget {
  final int weekNumber;
  const WeekNumber({Key key, this.weekNumber}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final weekTranslation = Translator.of(context).translate.week;
    return Tts(
      data: '$weekTranslation ${(weekNumber ?? '')}',
      child: SizedBox(
        width: 24.s,
        child: Text(
          weekNumber?.toString() ?? weekTranslation[0],
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
