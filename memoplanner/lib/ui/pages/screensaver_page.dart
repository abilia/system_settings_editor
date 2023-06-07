import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ScreensaverPage extends StatelessWidget {
  const ScreensaverPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNight = context.select((DayPartCubit cubit) => cubit.state.isNight);
    final clockType = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.clockType);
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
    final appBarSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.dayAppBar);
    final dayParts = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayParts);

    final time = context.watch<ClockBloc>().state;
    return Padding(
      padding: layout.screensaver.titleBarPadding,
      child: AppBarTitle(
        style: (Theme.of(context).textTheme.headlineMedium ?? headlineMedium)
            .apply(color: AbiliaColors.white),
        rows: AppBarTitleRows.day(
          compactDay: true,
          settings: appBarSettings,
          currentTime: time,
          day: time.onlyDays(),
          dayPart: context.read<DayPartCubit>().state,
          dayParts: dayParts,
          langCode: Localizations.localeOf(context).toLanguageTag(),
          translator: Translator.of(context).translate,
        ),
      ),
    );
  }
}
