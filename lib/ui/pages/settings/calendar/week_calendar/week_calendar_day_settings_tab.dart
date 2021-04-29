import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/calendar/week_calendar/week_calendar_settings_cubit.dart';
import 'package:seagull/models/memoplanner_settings.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WeekSettingsTab extends StatelessWidget {
  const WeekSettingsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<WeekCalendarSettingsCubit, WeekCalendarSettingsState>(
        builder: (context, state) {
      final onDisplaDaysChanged = (WeekDisplayDays w) => context
          .read<WeekCalendarSettingsCubit>()
          .changeWeekCalendarSettings(state.copyWith(weekDisplayDays: w));
      final onWeekColorChanged = (WeekColor w) => context
          .read<WeekCalendarSettingsCubit>()
          .changeWeekCalendarSettings(state.copyWith(weekColor: w));
      return SettingsTab(
        children: [
          Tts(child: Text(t.display)),
          WeekCalendarDisplay(),
          RadioField(
            value: WeekDisplayDays.everyDay,
            groupValue: state.weekDisplayDays,
            onChanged: onDisplaDaysChanged,
            text: Text(t.everyDay),
          ),
          RadioField(
            value: WeekDisplayDays.weekdays,
            groupValue: state.weekDisplayDays,
            onChanged: onDisplaDaysChanged,
            text: Text(t.weekdays),
          ),
          Divider(),
          RadioField(
            value: WeekColor.captions,
            groupValue: state.weekColor,
            onChanged: onWeekColorChanged,
            text: Text(t.captions),
          ),
          RadioField(
            value: WeekColor.columns,
            groupValue: state.weekColor,
            onChanged: onWeekColorChanged,
            text: Text(t.columns),
          ),
        ],
      );
    });
  }
}

class WeekCalendarDisplay extends StatelessWidget {
  const WeekCalendarDisplay({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekStart = DateTime.now().firstInWeek();
    return Container(
      height: 148.s,
      decoration: BoxDecoration(
        color: AbiliaColors.white,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0.s),
        child:
            BlocBuilder<WeekCalendarSettingsCubit, WeekCalendarSettingsState>(
                builder: (context, state) {
          final days = state.weekDisplayDays.numberOfDays();
          return Column(
            children: [
              Row(
                children: List<DayHeading>.generate(days, (i) {
                  final day = weekStart.addDays(i);
                  return DayHeading(
                    day: day,
                    dayColor: DayColor.allDays,
                  );
                }),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List<DayColumn>.generate(days, (i) {
                  final day = weekStart.addDays(i);
                  return DayColumn(
                    day: day,
                    dayColor: DayColor.allDays,
                  );
                }),
              )
            ],
          );
        }),
      ),
    );
  }
}

class DayHeading extends StatelessWidget {
  final DateTime day;
  final DayColor dayColor;
  const DayHeading({
    Key key,
    @required this.day,
    @required this.dayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderSize = 1.s;
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    return Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.0.s),
        child: Container(
          decoration: BoxDecoration(
            color: dayTheme.borderColor,
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
            ),
          ),
          child: Container(
            height: 44.s,
            width: double.infinity,
            margin: EdgeInsetsDirectional.only(
                start: borderSize, end: borderSize, top: borderSize),
            decoration: BoxDecoration(
              color: dayTheme.color,
              borderRadius: BorderRadius.only(
                topLeft: innerRadiusFromBorderSize(borderSize),
                topRight: innerRadiusFromBorderSize(borderSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DayColumn extends StatelessWidget {
  final DateTime day;
  final DayColor dayColor;

  const DayColumn({
    Key key,
    @required this.day,
    @required this.dayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderSize = 1.s;
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(
          right: 2.s,
          left: 2.s,
        ),
        child:
            BlocBuilder<WeekCalendarSettingsCubit, WeekCalendarSettingsState>(
          builder: (context, state) => Container(
            decoration: BoxDecoration(
              color: state.weekColor == WeekColor.columns
                  ? dayTheme.secondaryColor
                  : AbiliaColors.white110,
              borderRadius: BorderRadius.only(
                bottomLeft: radius,
                bottomRight: radius,
              ),
            ),
            child: Container(
              width: double.infinity,
              height: 86.s,
              margin: EdgeInsetsDirectional.only(
                  start: borderSize, end: borderSize, bottom: borderSize),
              decoration: BoxDecoration(
                color: state.weekColor == WeekColor.columns
                    ? dayTheme.secondaryColor
                    : AbiliaColors.white110,
                borderRadius: BorderRadius.only(
                  bottomLeft: innerRadiusFromBorderSize(borderSize),
                  bottomRight: innerRadiusFromBorderSize(borderSize),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
