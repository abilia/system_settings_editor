import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MonthDisplaySettingsTab extends StatelessWidget {
  const MonthDisplaySettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final monthCalendarCubit = context.watch<MonthCalendarSettingsCubit>();
    final settings = monthCalendarCubit.state;
    void onWeekColorChanged(int? index) => monthCalendarCubit
        .changeMonthCalendarSettings(settings.copyWith(colorTypeIndex: index));
    return SettingsTab(
      children: [
        Tts(child: Text(t.display)),
        Padding(
          padding: layout.settings.monthDaysPadding,
          child: const _MonthCalendarPreview(),
        ),
        SizedBox(
          height: layout.formPadding.verticalItemDistance,
        ),
        RadioField(
          key: TestKey.monthColorSwitch,
          value: WeekColor.captions.index,
          groupValue: settings.colorTypeIndex,
          onChanged: onWeekColorChanged,
          text: Text(t.captions),
        ),
        RadioField(
          value: WeekColor.columns.index,
          groupValue: settings.colorTypeIndex,
          onChanged: onWeekColorChanged,
          text: Text(t.columns),
        ),
      ],
    );
  }
}

class _MonthCalendarPreview extends StatelessWidget {
  const _MonthCalendarPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return Container(
      height: layout.settings.monthPreviewHeight,
      decoration: BoxDecoration(
        color: AbiliaColors.white,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(layout.formPadding.verticalItemDistance),
        child: Row(
          children: List.generate(
            DateTime.daysPerWeek,
            (d) => _MonthDayView(
              dayTheme: weekdayTheme(
                dayColor: DayColor.allDays,
                languageCode: languageCode,
                weekday: d + 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthDayView extends StatelessWidget {
  final DayTheme dayTheme;
  const _MonthDayView({
    required this.dayTheme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekColor = context.select(
        (MonthCalendarSettingsCubit cubit) => cubit.state.monthWeekColor);
    return Expanded(
      child: Container(
        margin: layout.settings.monthDaysPadding,
        foregroundDecoration: BoxDecoration(
          border: transparentBlackBorder,
          borderRadius: BorderRadius.circular(layout.monthCalendar.dayRadius),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: dayTheme.color,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(layout.monthCalendar.dayRadius),
                ),
              ),
              height: layout.settings.monthPreviewHeaderHeight,
            ),
            Expanded(
              child: Container(
                key: TestKey.monthDisplaySettingsDayView,
                decoration: BoxDecoration(
                  color: weekColor == WeekColor.columns
                      ? dayTheme.secondaryColor
                      : AbiliaColors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(layout.monthCalendar.dayRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
