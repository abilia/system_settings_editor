import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/week_calendar_settings.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WeekAppBarSettingsTab extends StatelessWidget {
  const WeekAppBarSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<WeekCalendarSettingsCubit, WeekCalendarSettingsState>(
      builder: (context, state) => SettingsTab(
        children: [
          Tts(child: Text(t.topField)),
          const WeekAppBarPreview(),
          SwitchField(
            value: state.showBrowseButtons,
            onChanged: (v) => context
                .read<WeekCalendarSettingsCubit>()
                .changeWeekCalendarSettings(
                    state.copyWith(showBrowseButtons: v)),
            child: Text(t.showBrowseButtons),
          ),
          SwitchField(
            value: state.showWeekNumber,
            onChanged: (v) => context
                .read<WeekCalendarSettingsCubit>()
                .changeWeekCalendarSettings(state.copyWith(showWeekNumber: v)),
            child: Text(t.showWeekNumber),
          ),
          SwitchField(
            value: state.showYear,
            onChanged: (v) => context
                .read<WeekCalendarSettingsCubit>()
                .changeWeekCalendarSettings(state.copyWith(showYear: v)),
            child: Text(t.showYear),
          ),
          SwitchField(
            value: state.showClock,
            onChanged: (v) => context
                .read<WeekCalendarSettingsCubit>()
                .changeWeekCalendarSettings(state.copyWith(showClock: v)),
            child: Text(t.showClock),
          ),
        ],
      ),
    );
  }
}

class WeekAppBarPreview extends StatelessWidget {
  const WeekAppBarPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState,
        WeekCalendarSettings>(
      selector: (state) => state.settings.weekCalendar,
      builder: (context, settings) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, currentTime) => AppBarPreview(
          showBrowseButtons: settings.showBrowseButtons,
          showClock: settings.showClock,
          rows: AppBarTitleRows.week(
            translator: Translator.of(context).translate,
            selectedDay: currentTime.onlyDays(),
            selectedWeekStart: currentTime.firstInWeek(),
            showWeekNumber: settings.showWeekNumber,
            showYear: settings.showYear,
            langCode: Localizations.localeOf(context).toLanguageTag(),
          ),
        ),
      ),
    );
  }
}
