import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MonthAppBarSettingsTab extends StatelessWidget {
  const MonthAppBarSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<MonthCalendarSettingsCubit, MonthCalendarSettingsState>(
      builder: (context, state) => SettingsTab(
        children: [
          Tts(child: Text(t.topField)),
          const _MonthAppBarPreview(),
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
  const _MonthAppBarPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthCalendarSettingsCubit, MonthCalendarSettingsState>(
      builder: (context, state) => BlocBuilder<ClockBloc, DateTime>(
        builder: (context, currentTime) => AppBarPreview(
          showBrowseButtons: state.browseButtons,
          showClock: state.clock,
          rows: AppBarTitleRows.month(
            selectedDay: currentTime.onlyDays(),
            currentTime: currentTime,
            langCode: Localizations.localeOf(context).toLanguageTag(),
            showYear: state.year,
          ),
        ),
      ),
    );
  }
}
