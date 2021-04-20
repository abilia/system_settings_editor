import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DayAppBarSettingsTab extends StatelessWidget {
  const DayAppBarSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsTab(
      children: [
        Tts(child: Text(t.topField)),
        DayAppBarPreview(),
      ],
    );
  }
}

class DayAppBarPreview extends StatelessWidget {
  const DayAppBarPreview({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) =>
          BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) => CalendarAppBar(
          day: DateTime.now(),
          calendarDayColor: memoSettingsState.calendarDayColor,
          rows: AppBarTitleRows.day(
            displayWeekDay: true,
            displayPartOfDay: true,
            displayDate: true,
            currentTime: DateTime.now(),
            day: DateTime.now(),
            dayParts: memoSettingsState.dayParts,
            langCode: Localizations.localeOf(context).toLanguageTag(),
            translator: Translator.of(context).translate,
          ),
        ),
      ),
    );
  }
}
