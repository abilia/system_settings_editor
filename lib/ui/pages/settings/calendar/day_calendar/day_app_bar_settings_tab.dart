import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class DayAppBarSettingsTab extends StatelessWidget {
  const DayAppBarSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettingsState>(
      builder: (context, state) => SettingsTab(
        children: [
          Tts(child: Text(t.topField)),
          DayAppBarPreview(),
          SwitchField(
            text: Text(t.showBrowseButtons),
            value: state.showBrowseButtons,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(
                    state.copyWith(showBrowseButtons: v)),
          ),
          SwitchField(
            text: Text(t.showWeekday),
            value: state.showWeekday,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(state.copyWith(showWeekday: v)),
          ),
          SwitchField(
            text: Text(t.showDayPeriod),
            value: state.showDayPeriod,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(state.copyWith(showDayPeriod: v)),
          ),
          SwitchField(
            text: Text(t.showDate),
            value: state.showDate,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(state.copyWith(showDate: v)),
          ),
          SwitchField(
            text: Text(t.showClock),
            value: state.showClock,
            onChanged: (v) => context
                .read<DayCalendarSettingsCubit>()
                .changeDayCalendarSettings(state.copyWith(showClock: v)),
          ),
        ],
      ),
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
        builder: (context, memoSettingsState) => Container(
          height: CalendarAppBar.size.height,
          child: CalendarAppBar(
            leftAction: state.showBrowseButtons
                ? ActionButton(
                    onPressed: () => {},
                    child: Icon(AbiliaIcons.return_to_previous_page),
                  )
                : null,
            rightAction: state.showBrowseButtons
                ? ActionButton(
                    onPressed: () => {},
                    child: Icon(AbiliaIcons.go_to_next_page),
                  )
                : null,
            day: DateTime.now(),
            calendarDayColor: memoSettingsState.calendarDayColor,
            rows: AppBarTitleRows.day(
              displayWeekDay: state.showWeekday,
              displayPartOfDay: state.showDayPeriod,
              displayDate: state.showDate,
              compress: state.showClock && state.showBrowseButtons,
              currentTime: DateTime.now(),
              day: DateTime.now(),
              dayParts: memoSettingsState.dayParts,
              langCode: Localizations.localeOf(context).toLanguageTag(),
              translator: Translator.of(context).translate,
            ),
            showClock: state.showClock,
          ),
        ),
      ),
    );
  }
}
