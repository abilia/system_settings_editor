import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class MonthDisplaySettingsTab extends StatelessWidget {
  const MonthDisplaySettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<MonthCalendarSettingsCubit, MonthCalendarSettingsState>(
      builder: (context, state) {
        onWeekColorChanged(WeekColor? w) => context
            .read<MonthCalendarSettingsCubit>()
            .changeMonthCalendarSettings(state.copyWith(color: w));
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
              key: TestKey.monthColorSwith,
              value: WeekColor.captions,
              groupValue: state.color,
              onChanged: onWeekColorChanged,
              text: Text(t.captions),
            ),
            RadioField(
              value: WeekColor.columns,
              groupValue: state.color,
              onChanged: onWeekColorChanged,
              text: Text(t.columns),
            ),
          ],
        );
      },
    );
  }
}

class _MonthCalendarPreview extends StatelessWidget {
  const _MonthCalendarPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return SizedBox(
      height: layout.settings.monthPreviewHeight,
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
      )),
    );
  }
}

class _MonthDayView extends StatelessWidget {
  final DayTheme dayTheme;
  const _MonthDayView({
    Key? key,
    required this.dayTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: BlocBuilder<MonthCalendarSettingsCubit,
                  MonthCalendarSettingsState>(
                buildWhen: (previous, current) =>
                    previous.color != current.color,
                builder: (context, state) => Container(
                  key: TestKey.monthDisplaySettingsDayView,
                  decoration: BoxDecoration(
                    color: state.color == WeekColor.columns
                        ? dayTheme.secondaryColor
                        : AbiliaColors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(layout.monthCalendar.dayRadius),
                    ),
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
