import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WeekSettingsTab extends StatelessWidget {
  const WeekSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<WeekCalendarSettingsCubit, WeekCalendarSettingsState>(
        builder: (context, state) {
      void onDisplaDaysChanged(WeekDisplayDays? w) => context
          .read<WeekCalendarSettingsCubit>()
          .changeWeekCalendarSettings(state.copyWith(weekDisplayDays: w));
      void onWeekColorChanged(WeekColor? w) => context
          .read<WeekCalendarSettingsCubit>()
          .changeWeekCalendarSettings(state.copyWith(weekColor: w));
      return SettingsTab(
        children: [
          Tts(child: Text(t.display)),
          const WeekCalendarDisplay(),
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
          const Divider(),
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
  const WeekCalendarDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekStart = context.read<ClockBloc>().state.firstInWeek();
    return Container(
      height: layout.settings.weekCalendarHeight,
      decoration: BoxDecoration(
        color: AbiliaColors.white,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(layout.formPadding.verticalItemDistance),
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
    Key? key,
    required this.day,
    required this.dayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderSize = layout.borders.thin;
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    return Flexible(
      child: Padding(
        padding: layout.settings.weekDaysPadding,
        child: Container(
          decoration: BoxDecoration(
            color: dayTheme.borderColor,
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
            ),
          ),
          child: Container(
            height: layout.settings.weekCalendarHeadingHeight,
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
    Key? key,
    required this.day,
    required this.dayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderSize = layout.borders.thin;
    final dayTheme = weekdayTheme(
      dayColor: dayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: day.weekday,
    );
    return Flexible(
      child: Padding(
        padding: layout.settings.weekDaysPadding,
        child:
            BlocBuilder<WeekCalendarSettingsCubit, WeekCalendarSettingsState>(
          builder: (context, state) => Container(
            decoration: BoxDecoration(
              color: state.weekColor == WeekColor.columns &&
                      dayTheme.secondaryColor != AbiliaColors.white
                  ? dayTheme.secondaryColor
                  : AbiliaColors.white110,
              borderRadius: BorderRadius.only(
                bottomLeft: radius,
                bottomRight: radius,
              ),
            ),
            child: Container(
              width: double.infinity,
              height: layout.settings.weekDayHeight,
              margin: EdgeInsetsDirectional.only(
                  start: borderSize, end: borderSize, bottom: borderSize),
              decoration: BoxDecoration(
                color: state.weekColor == WeekColor.columns
                    ? dayTheme.secondaryColor
                    : AbiliaColors.white,
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
