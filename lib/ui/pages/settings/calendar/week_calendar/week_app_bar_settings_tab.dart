import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class WeekAppBarSettingsTab extends StatelessWidget {
  const WeekAppBarSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final state = context.watch<WeekCalendarSettingsCubit>().state;
    return SettingsTab(
      children: [
        Tts(child: Text(t.topField)),
        const WeekAppBarPreview(),
        SwitchField(
          value: state.showBrowseButtons,
          onChanged: (v) => context
              .read<WeekCalendarSettingsCubit>()
              .changeWeekCalendarSettings(state.copyWith(showBrowseButtons: v)),
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
    );
  }
}

class WeekAppBarPreview extends StatelessWidget {
  const WeekAppBarPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeekCalendarSettingsCubit>().state;
    final currentTime = context.watch<ClockBloc>().state;
    return AppBarPreview(
      showBrowseButtons: state.showBrowseButtons,
      showClock: state.showClock,
      rows: AppBarTitleRows.week(
        translator: Translator.of(context).translate,
        selectedDay: currentTime.onlyDays(),
        selectedWeekStart: currentTime.firstInWeek(),
        showWeekNumber: state.showWeekNumber,
        showYear: state.showYear,
        langCode: Localizations.localeOf(context).toLanguageTag(),
      ),
    );
  }
}
