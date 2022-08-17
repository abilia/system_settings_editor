import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DayAppBarSettingsTab extends StatelessWidget {
  const DayAppBarSettingsTab({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) => SettingsTab(
        children: [
          Tts(child: Text(t.topField)),
          const DayAppBarPreview(),
          SwitchField(
            value: state.showBrowseButtons,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(
                    state.copyWith(showBrowseButtons: v)),
            child: Text(t.showBrowseButtons),
          ),
          SwitchField(
            value: state.showWeekday,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(state.copyWith(showWeekday: v)),
            child: Text(t.showWeekday),
          ),
          SwitchField(
            value: state.showDayPeriod,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(state.copyWith(showDayPeriod: v)),
            child: Text(t.showDayPeriod),
          ),
          SwitchField(
            value: state.showDate,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(state.copyWith(showDate: v)),
            child: Text(t.showDate),
          ),
          SwitchField(
            value: state.showClock,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(state.copyWith(showClock: v)),
            child: Text(t.showClock),
          ),
        ],
      ),
    );
  }
}

class DayAppBarPreview extends StatelessWidget {
  const DayAppBarPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayParts = context.select((MemoplannerSettingBloc settings) =>
        settings.state.settings.calendar.dayParts);
    final settingsState = context.watch<DayCalendarSettingsCubit>().state;
    final currentTime = context.watch<ClockBloc>().state;
    return AppBarPreview(
      showBrowseButtons: settingsState.showBrowseButtons,
      showClock: settingsState.showClock,
      rows: AppBarTitleRows.day(
        displayWeekDay: settingsState.showWeekday,
        displayPartOfDay: settingsState.showDayPeriod,
        displayDate: settingsState.showDate,
        currentTime: currentTime,
        day: currentTime.onlyDays(),
        dayParts: dayParts,
        dayPart: context.read<DayPartCubit>().state,
        langCode: Localizations.localeOf(context).toLanguageTag(),
        translator: Translator.of(context).translate,
      ),
    );
  }
}
