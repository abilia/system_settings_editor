import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';
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
          WeekAppBarPreview(),
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
    return BlocBuilder<WeekCalendarSettingsCubit, WeekCalendarSettingsState>(
      builder: (context, state) =>
          BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) =>
            BlocBuilder<ClockBloc, DateTime>(
          builder: (context, currentTime) => Container(
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
              rows: AppBarTitleRows.week(
                translator: Translator.of(context).translate,
                selectedDay: currentTime.onlyDays(),
                selectedWeekStart: currentTime.firstInWeek(),
                showWeekNumber: state.showWeekNumber,
                showYear: state.showYear,
                langCode: Localizations.localeOf(context).toLanguageTag(),
              ),
              showClock: state.showClock,
            ),
          ),
        ),
      ),
    );
  }
}
