import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class DayColorsSettingsTab extends StatelessWidget {
  const DayColorsSettingsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return BlocBuilder<GeneralCalendarSettingsCubit, GeneralCalendarSettings>(
      builder: (context, state) {
        return SettingsTab(
          children: [
            Tts(child: Text(Translator.of(context).translate.dayColours)),
            MonthHeading(
              showLeadingWeekShort: false,
              dayThemes: List.generate(
                DateTime.daysPerWeek,
                (d) => weekdayTheme(
                  dayColor: state.dayColor,
                  languageCode: languageCode,
                  weekday: d + 1,
                ),
              ),
            ),
            ...DayColor.values.map(
              (dc) => RadioField<DayColor>(
                key: Key('$dc'),
                text: Text(_title(dc, Translator.of(context).translate)),
                value: dc,
                groupValue: state.dayColor,
                onChanged: (v) => context
                    .read<GeneralCalendarSettingsCubit>()
                    .changeSettings(state.copyWith(dayColor: v)),
              ),
            )
          ],
        );
      },
    );
  }

  String _title(DayColor dayColor, Translated translator) {
    switch (dayColor) {
      case DayColor.allDays:
        return translator.allDays;
      case DayColor.saturdayAndSunday:
        return translator.saturdayAndSunday;
      case DayColor.noColors:
        return translator.noDayColours;
      default:
        return dayColor.toString();
    }
  }
}
