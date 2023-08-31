import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class DayAppBarSettingsTab extends StatelessWidget {
  const DayAppBarSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return BlocBuilder<DayCalendarSettingsCubit, DayCalendarSettings>(
      builder: (context, settings) {
        final dayCalendar = context.read<DayCalendarSettingsCubit>();
        final appBar = dayCalendar.state.appBar;
        return SettingsTab(
          children: [
            Tts(child: Text(translate.topField)),
            const DayAppBarPreview(),
            SwitchField(
              value: appBar.showBrowseButtons,
              onChanged: (v) => dayCalendar
                  .changeAppBar(appBar.copyWith(showBrowseButtons: v)),
              child: Text(translate.showBrowseButtons),
            ),
            SwitchField(
              value: appBar.showWeekday,
              onChanged: (v) =>
                  dayCalendar.changeAppBar(appBar.copyWith(showWeekday: v)),
              child: Text(translate.showWeekday),
            ),
            SwitchField(
              value: appBar.showDayPeriod,
              onChanged: (v) =>
                  dayCalendar.changeAppBar(appBar.copyWith(showDayPeriod: v)),
              child: Text(translate.showDayPeriod),
            ),
            SwitchField(
              value: appBar.showDate,
              onChanged: (v) =>
                  dayCalendar.changeAppBar(appBar.copyWith(showDate: v)),
              child: Text(translate.showDate),
            ),
            SwitchField(
              value: appBar.showClock,
              onChanged: (v) =>
                  dayCalendar.changeAppBar(appBar.copyWith(showClock: v)),
              child: Text(translate.showClock),
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
    final currentTime = context.watch<ClockCubit>().state;
    return AppBarPreview(
      showBrowseButtons: appBarSettings.showBrowseButtons,
      showClock: appBarSettings.showClock,
      rows: AppBarTitleRows.day(
        settings: appBarSettings,
        currentTime: currentTime,
        day: currentTime.onlyDays(),
        dayParts: dayParts,
        dayPart: context.read<DayPartCubit>().state,
        langCode: Localizations.localeOf(context).toLanguageTag(),
        translate: Lt.of(context),
      ),
    );
  }
}
