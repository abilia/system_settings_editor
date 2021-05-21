import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MonthAppBarSettingsTab extends StatelessWidget {
  const MonthAppBarSettingsTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<MonthCalendarSettingsCubit, MonthCalendarSettingsState>(
      builder: (context, state) => SettingsTab(
        children: [
          Tts(child: Text(t.topField)),
          _MonthAppBarPreview(),
          SwitchField(
            value: state.browseButtons,
            onChanged: (v) => context
                .read<MonthCalendarSettingsCubit>()
                .changeMonthCalendarSettings(state.copyWith(browseButtons: v)),
            child: Text(t.showBrowseButtons),
          ),
          SwitchField(
            value: state.year,
            onChanged: (v) => context
                .read<MonthCalendarSettingsCubit>()
                .changeMonthCalendarSettings(state.copyWith(year: v)),
            child: Text(t.showYear),
          ),
          SwitchField(
            value: state.clock,
            onChanged: (v) => context
                .read<MonthCalendarSettingsCubit>()
                .changeMonthCalendarSettings(state.copyWith(clock: v)),
            child: Text(t.showClock),
          ),
        ],
      ),
    );
  }
}

class _MonthAppBarPreview extends StatelessWidget {
  const _MonthAppBarPreview({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarSettingsCubit, MonthCalendarSettingsState>(
      builder: (context, state) =>
          BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) =>
            BlocBuilder<ClockBloc, DateTime>(
          builder: (context, currentTime) => Container(
            height: CalendarAppBar.size.height,
            child: CalendarAppBar(
              leftAction: state.browseButtons
                  ? ActionButton(
                      onPressed: () => {},
                      child: Icon(AbiliaIcons.return_to_previous_page),
                    )
                  : null,
              rightAction: state.browseButtons
                  ? ActionButton(
                      onPressed: () => {},
                      child: Icon(AbiliaIcons.go_to_next_page),
                    )
                  : null,
              day: currentTime,
              rows: AppBarTitleRows.month(
                currentTime: currentTime,
                langCode: Localizations.localeOf(context).toLanguageTag(),
                showYear: state.year,
              ),
              showClock: state.clock,
            ),
          ),
        ),
      ),
    );
  }
}
