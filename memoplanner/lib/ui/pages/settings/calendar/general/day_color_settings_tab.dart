import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class DayColorsSettingsTab extends StatelessWidget {
  const DayColorsSettingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return BlocBuilder<GeneralCalendarSettingsCubit, GeneralCalendarSettings>(
      builder: (context, state) {
        return SettingsTab(
          children: [
            Tts(child: Text(Lt.of(context).dayColours)),
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
                text: Text(_title(dc, Lt.of(context))),
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

  String _title(DayColor dayColor, Lt translate) {
    switch (dayColor) {
      case DayColor.allDays:
        return translate.allDays;
      case DayColor.saturdayAndSunday:
        return translate.saturdayAndSunday;
      case DayColor.noColors:
        return translate.noDayColours;
      default:
        return dayColor.toString();
    }
  }
}
