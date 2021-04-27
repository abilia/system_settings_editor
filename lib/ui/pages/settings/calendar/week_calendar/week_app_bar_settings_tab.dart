import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WeekAppBarSettingsTab extends StatelessWidget {
  const WeekAppBarSettingsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<WeekCalendarSettingsCubit, WeekCalendarSettingsState>(
      builder: (context, state) => SettingsTab(
        children: [
          Tts(child: Text(t.topField)),
          WeekAppBarPreview(),
          SwitchField(
            text: Text(t.showBrowseButtons),
            value: state.showBrowseButtons,
            onChanged: (v) => context
                .read<WeekCalendarSettingsCubit>()
                .changeWeelCalendarSettings(
                    state.copyWith(showBrowseButtons: v)),
          ),
          SwitchField(
            text: Text(t.showWeekNumber),
            value: state.showWeekNumber,
            onChanged: (v) => context
                .read<WeekCalendarSettingsCubit>()
                .changeWeelCalendarSettings(state.copyWith(showWeekNumber: v)),
          ),
          SwitchField(
            text: Text(t.showYear),
            value: state.showYear,
            onChanged: (v) => context
                .read<WeekCalendarSettingsCubit>()
                .changeWeelCalendarSettings(state.copyWith(showYear: v)),
          ),
          SwitchField(
            text: Text(t.showClock),
            value: state.showClock,
            onChanged: (v) => context
                .read<WeekCalendarSettingsCubit>()
                .changeWeelCalendarSettings(state.copyWith(showClock: v)),
          ),
        ],
      ),
    );
  }
}

class WeekAppBarPreview extends StatelessWidget {
  const WeekAppBarPreview({Key key}) : super(key: key);

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
                compressDay: state.showBrowseButtons && state.showClock,
              ),
              showClock: state.showClock,
            ),
          ),
        ),
      ),
    );
  }
}
