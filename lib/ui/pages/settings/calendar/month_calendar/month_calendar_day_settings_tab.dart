import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
              padding: EdgeInsets.only(left: 4.0.s, right: 4.s, bottom: 8.s),
              child: _MonthCalendarPreview(),
            ),
            RadioField(
              key: TestKey.monthColorSwith,
              value: WeekColor.captions,
              groupValue: state.color,
              onChanged: onWeekColorChanged,
              text: Text(t.headings),
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
      height: 96.s,
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
        padding: EdgeInsets.symmetric(horizontal: 4.s),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: dayTheme.color,
                borderRadius:
                    BorderRadius.vertical(top: MonthDayView.monthDayRadius),
              ),
              height: 32.s,
            ),
            Expanded(
              child: BlocBuilder<MonthCalendarSettingsCubit,
                  MonthCalendarSettingsState>(
                buildWhen: (previous, current) =>
                    previous.color != current.color,
                builder: (context, state) => MonthDayContainer(
                  color: state.color == WeekColor.columns
                      ? dayTheme.secondaryColor
                      : AbiliaColors.white110,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
