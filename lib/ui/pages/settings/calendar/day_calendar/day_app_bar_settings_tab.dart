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
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) =>
          BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) =>
            BlocBuilder<ClockBloc, DateTime>(
          builder: (context, currentTime) => SizedBox(
            height: CalendarAppBar.size.height,
            child: CalendarAppBar(
              leftAction: state.showBrowseButtons
                  ? ActionButton(
                      onPressed: () => {},
                      child: const Icon(AbiliaIcons.returnToPreviousPage),
                    )
                  : null,
              rightAction: state.showBrowseButtons
                  ? ActionButton(
                      onPressed: () => {},
                      child: const Icon(AbiliaIcons.goToNextPage),
                    )
                  : null,
              day: DateTime.now(),
              calendarDayColor: memoSettingsState.calendarDayColor,
              rows: AppBarTitleRows.day(
                displayWeekDay: state.showWeekday,
                displayPartOfDay: state.showDayPeriod,
                displayDate: state.showDate,
                currentTime: currentTime,
                day: currentTime.onlyDays(),
                dayParts: memoSettingsState.dayParts,
                langCode: Localizations.localeOf(context).toLanguageTag(),
                translator: Translator.of(context).translate,
              ),
              showClock: state.showClock,
            ),
          ),
        ),
      ),
    );
  }
}
