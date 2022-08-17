import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/datetime.dart';

class ScreenSaverPage extends StatelessWidget {
  const ScreenSaverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNight = context.select((DayPartCubit cubit) => cubit.state.isNight);
    return Listener(
      onPointerDown: (event) => Navigator.of(context).pop(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AbiliaColors.black,
        body: Opacity(
          opacity: isNight ? 0.3 : 1,
          child: Column(
            children: [
              const ScreenSaverAppBar(),
              Padding(
                padding: layout.screenSaver.clockPadding,
                child: BlocSelector<MemoplannerSettingBloc,
                    MemoplannerSettingsState, ClockType>(
                  selector: (state) => state.settings.calendar.clockType,
                  builder: (context, clockType) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (clockType != ClockType.digital)
                        Padding(
                          padding: EdgeInsets.only(
                              right: layout.screenSaver.clockSeparation),
                          child: ScreensaverAnalogClock(isNight: isNight),
                        ),
                      if (clockType != ClockType.analogue)
                        DigitalClock(
                          style: layout.screenSaver.digitalClockTextStyle,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreenSaverAppBar extends StatelessWidget {
  const ScreenSaverAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) => Padding(
          padding: layout.screenSaver.titleBarPadding,
          child: BlocBuilder<ClockBloc, DateTime>(
            builder: (state, time) => AppBarTitle(
              style: (Theme.of(context).textTheme.headline4 ?? headline4)
                  .apply(color: AbiliaColors.white),
              rows: AppBarTitleRows.day(
                compactDay: true,
                displayWeekDay: memoSettingsState.activityDisplayWeekDay,
                displayPartOfDay: memoSettingsState.activityDisplayDayPeriod,
                displayDate: memoSettingsState.activityDisplayDate,
                currentTime: time,
                day: time.onlyDays(),
                dayPart: context.read<DayPartCubit>().state,
                dayParts: memoSettingsState.settings.calendar.dayParts,
                langCode: Localizations.localeOf(context).toLanguageTag(),
                translator: Translator.of(context).translate,
              ),
            ),
          ),
        ),
      );
}
