import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MonthListPreview extends StatelessWidget {
  final List<DayTheme> dayThemes;

  const MonthListPreview({
    Key? key,
    required this.dayThemes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          left: 8.s,
          top: 12.s,
          right: 8.s,
        ),
        child: Column(
          children: [
            BlocBuilder<DayPickerBloc, DayPickerState>(
              builder: (context, state) => MonthDayPreviewHeading(
                dayTheme: dayThemes[state.day.weekday],
                day: state.day,
              ),
            ),
            Expanded(
              child: MonthPreview(),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthPreview extends StatelessWidget {
  const MonthPreview({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 1.s, right: 1.s),
      decoration: BoxDecoration(color: AbiliaColors.transparentBlack30),
      child: Container(
        decoration: BoxDecoration(color: AbiliaColors.white110),
        child: BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
          buildWhen: (oldState, newState) =>
              (oldState is ActivitiesOccasionLoaded &&
                  newState is ActivitiesOccasionLoaded &&
                  oldState.day == newState.day) ||
              oldState.runtimeType != newState.runtimeType,
          builder: (context, activityState) =>
              activityState is ActivitiesOccasionLoaded
                  ? Agenda(activityState: activityState)
                  : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class MonthDayPreviewHeading extends StatelessWidget {
  const MonthDayPreviewHeading({
    Key? key,
    required this.dayTheme,
    required this.day,
  }) : super(key: key);

  final DayTheme dayTheme;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final text = DateFormat('EEEE, MMMM d').format(day);
    return Tts(
      data: text,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.s),
        height: 48.s,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: radius),
          color: dayTheme.color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: dayTheme.theme.textTheme.subtitle1),
            SizedBox(height: 40.s, width: 40.s, child: Placeholder()),
          ],
        ),
      ),
    );
  }
}

class MonthDayViewCompact extends StatelessWidget {
  final MonthDay day;
  final DayTheme dayTheme;
  const MonthDayViewCompact(
    this.day, {
    Key? key,
    required this.dayTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts(
      data:
          DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
              .format(day.day),
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<DayPickerBloc>(context).add(GoTo(day: day.day));
        },
        child: BlocBuilder<DayPickerBloc, DayPickerState>(
          builder: (context, dayPickerState) => Container(
            foregroundDecoration: day.isCurrent
                ? BoxDecoration(
                    border: currentActivityBorder,
                    borderRadius: MonthDayView.monthDayborderRadius,
                  )
                : dayPickerState.day.isAtSameDay(day.day)
                    ? BoxDecoration(
                        border: selectedActivityBorder,
                        borderRadius: MonthDayView.monthDayborderRadius,
                      )
                    : null,
            child: Container(
              decoration: BoxDecoration(
                color: dayTheme.color,
                borderRadius: MonthDayView.monthDayborderRadius,
              ),
              height: 24.s,
              padding: EdgeInsets.symmetric(horizontal: 4.s),
              child: DefaultTextStyle(
                style: dayTheme.theme.textTheme.subtitle2!,
                child: Row(
                  children: [
                    Text('${day.day.day}'),
                    Spacer(),
                    if (day.hasActivities)
                      ColorDot(color: dayTheme.theme.accentColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
