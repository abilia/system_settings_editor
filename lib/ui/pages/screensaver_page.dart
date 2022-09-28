import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ScreensaverPage extends StatelessWidget {
  const ScreensaverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNight = context.select((DayPartCubit cubit) => cubit.state.isNight);
    final clockType = context.select((MemoplannerSettingBloc bloc) =>
        bloc.state.settings.calendar.clockType);
    return Scaffold(
      backgroundColor: AbiliaColors.black,
      body: Opacity(
        opacity: isNight ? 0.3 : 1,
        child: Column(
          children: [
            const _ScreensaverAppBar(),
            Padding(
              padding: layout.screensaver.clockPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (clockType != ClockType.digital)
                    Padding(
                      padding: EdgeInsets.only(
                          right: layout.screensaver.clockSeparation),
                      child: ScreensaverAnalogClock(isNight: isNight),
                    ),
                  if (clockType != ClockType.analogue)
                    DigitalClock(
                      style: layout.screensaver.digitalClockTextStyle,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreensaverAppBar extends StatelessWidget {
  const _ScreensaverAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memoSettingsState = context.watch<MemoplannerSettingBloc>().state;
    final appBarSettings = memoSettingsState.settings.dayCalendar.appBar;

    final time = context.watch<ClockBloc>().state;
    return Padding(
      padding: layout.screensaver.titleBarPadding,
      child: AppBarTitle(
        style: (Theme.of(context).textTheme.headline4 ?? headline4)
            .apply(color: AbiliaColors.white),
        rows: AppBarTitleRows.day(
          compactDay: true,
          displayWeekDay: appBarSettings.showDayPeriod,
          displayPartOfDay: appBarSettings.showWeekday,
          displayDate: appBarSettings.showDate,
          currentTime: time,
          day: time.onlyDays(),
          dayPart: context.read<DayPartCubit>().state,
          dayParts: memoSettingsState.settings.calendar.dayParts,
          langCode: Localizations.localeOf(context).toLanguageTag(),
          translator: Translator.of(context).translate,
        ),
      ),
    );
  }
}
