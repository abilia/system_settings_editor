import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DayAppBarSettingsTab extends StatelessWidget {
  const DayAppBarSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettings>(
      builder: (context, settings) {
        final dayCalendar = context.read<DayCalendarSettingsCubit>();
        final appBar = dayCalendar.state.appBar;
        return SettingsTab(
          children: [
            Tts(child: Text(t.topField)),
            const DayAppBarPreview(),
            SwitchField(
              value: appBar.showBrowseButtons,
              onChanged: (v) => dayCalendar.changeSettings(settings.copyWith(
                  appBar: appBar.copyWith(showBrowseButtons: v))),
              child: Text(t.showBrowseButtons),
            ),
            SwitchField(
              value: appBar.showWeekday,
              onChanged: (v) => dayCalendar.changeSettings(
                  settings.copyWith(appBar: appBar.copyWith(showWeekday: v))),
              child: Text(t.showWeekday),
            ),
            SwitchField(
              value: appBar.showDayPeriod,
              onChanged: (v) => dayCalendar.changeSettings(
                  settings.copyWith(appBar: appBar.copyWith(showDayPeriod: v))),
              child: Text(t.showDayPeriod),
            ),
            SwitchField(
              value: appBar.showDate,
              onChanged: (v) => dayCalendar.changeSettings(
                  settings.copyWith(appBar: appBar.copyWith(showDate: v))),
              child: Text(t.showDate),
            ),
            SwitchField(
              value: appBar.showClock,
              onChanged: (v) => dayCalendar.changeSettings(
                  settings.copyWith(appBar: appBar.copyWith(showClock: v))),
              child: Text(t.showClock),
            ),
          ],
        );
      },
    );
  }
}

class DayAppBarPreview extends StatelessWidget {
  const DayAppBarPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayParts = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayParts);
    final appBarSettings =
        context.select((DayCalendarSettingsCubit cubit) => cubit.state.appBar);
    final currentTime = context.watch<ClockBloc>().state;
    return AppBarPreview(
      showBrowseButtons: appBarSettings.showBrowseButtons,
      showClock: appBarSettings.showClock,
      rows: AppBarTitleRows.day(
        displayWeekDay: appBarSettings.showWeekday,
        displayPartOfDay: appBarSettings.showDayPeriod,
        displayDate: appBarSettings.showDate,
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
