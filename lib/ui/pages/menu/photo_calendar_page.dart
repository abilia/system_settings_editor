import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PhotoCalendarPage extends StatelessWidget {
  const PhotoCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MemoplannerSettingBloc>().state;
    final currentTime = context.watch<ClockBloc>().state;
    final theme = weekdayTheme(
      dayColor: state.calendarDayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: currentTime.weekday,
    );
    final style = GoogleFonts.roboto(
      textStyle: TextStyle(
        fontSize: layout.photoCalendarLayout.digitalClockFontSize,
        height: 1,
        fontWeight: layout.photoCalendarLayout.digitalClockFontWeight,
        leadingDistribution: TextLeadingDistribution.even,
      ),
    );

    return Theme(
      data: theme.theme,
      child: Scaffold(
        appBar: const PhotoCalendarAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: layout.photoCalendarLayout.clockRowHeight,
                color: theme.color,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.clockType != ClockType.digital)
                          SizedBox(
                            height: layout.photoCalendarLayout.analogClockSize +
                                layout.clock.borderWidth * 2,
                            width: layout.photoCalendarLayout.analogClockSize,
                            child: const FittedBox(child: AnalogClock()),
                          ),
                        if (state.clockType == ClockType.analogueDigital)
                          SizedBox(
                              width: layout.photoCalendarLayout.clockDistance),
                        if (state.clockType != ClockType.analogue)
                          DigitalClock(style: style),
                      ],
                    ).pad(
                      state.clockType == ClockType.digital
                          ? layout.photoCalendarLayout.digitalClockPadding
                          : layout.photoCalendarLayout.analogClockPadding,
                    ),
                    Positioned(
                      bottom: layout.photoCalendarLayout.backButtonPosition.dy,
                      right: layout.photoCalendarLayout.backButtonPosition.dx,
                      child: IconActionButton(
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: const Icon(AbiliaIcons.month),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: SlideShow(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SlideShow extends StatelessWidget {
  const SlideShow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final poppyImage = Image.asset(
      'assets/graphics/poppy_field.jpg',
      fit: BoxFit.cover,
    );
    return BlocProvider<SlideShowCubit>(
      create: (context) => SlideShowCubit(
        sortableBloc: context.read<SortableBloc>(),
      ),
      child: BlocBuilder<SlideShowCubit, SlideShowState>(
        builder: (context, state) {
          final currentFileId = state.currentFileId;
          final currentPath = state.currentPath;
          return AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: GestureDetector(
              key: currentFileId != null ? Key(currentFileId) : null,
              onDoubleTap: () => context.read<SlideShowCubit>().next(),
              child: SizedBox.expand(
                child: currentFileId != null && currentPath != null
                    ? PhotoCalendarImage(
                        fileId: currentFileId,
                        filePath: currentPath,
                        errorContent: poppyImage,
                      )
                    : poppyImage,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PhotoCalendarAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PhotoCalendarAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => layout.photoCalendarLayout.appBarSize;

  @override
  Widget build(BuildContext context) {
    final memoSettingsState = context.watch<MemoplannerSettingBloc>().state;
    final time = context.watch<ClockBloc>().state;
    return CalendarAppBar(
      textStyle: Theme.of(context).textTheme.headline4,
      day: time.onlyDays(),
      calendarDayColor: memoSettingsState.calendarDayColor,
      rows: AppBarTitleRows.day(
        displayWeekDay: memoSettingsState.activityDisplayWeekDay,
        displayPartOfDay: memoSettingsState.activityDisplayDayPeriod,
        displayDate: memoSettingsState.activityDisplayDate,
        currentTime: time,
        day: time.onlyDays(),
        dayParts: memoSettingsState.dayParts,
        langCode: Localizations.localeOf(context).toLanguageTag(),
        translator: Translator.of(context).translate,
        compactDay: false,
      ),
      showClock: false,
    );
  }
}
