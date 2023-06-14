import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class WeekAppBarSettingsTab extends StatelessWidget {
  const WeekAppBarSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Lt.of(context);
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
          value: state.showYearAndMonth,
          onChanged: (v) => context
              .read<WeekCalendarSettingsCubit>()
              .changeWeekCalendarSettings(state.copyWith(showYearAndMonth: v)),
          child: Text(t.showMonthAndYear),
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
    final weekCalendarSettings =
        context.watch<WeekCalendarSettingsCubit>().state;
    final currentTime = context.watch<ClockBloc>().state;
    return AppBarPreview(
      showBrowseButtons: weekCalendarSettings.showBrowseButtons,
      showClock: weekCalendarSettings.showClock,
      rows: AppBarTitleRows.week(
        translator: Lt.of(context),
        selectedDay: currentTime.onlyDays(),
        selectedWeekStart: currentTime.firstInWeek(),
        settings: weekCalendarSettings,
        langCode: Localizations.localeOf(context).toLanguageTag(),
      ),
    );
  }
}
