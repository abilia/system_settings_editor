import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class PhotoCalendarPage extends StatelessWidget {
  const PhotoCalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final photoCalendarLayout = layout.photoCalendarLayout;
    final functionsSettings =
        context.select((MemoplannerSettingsBloc bloc) => bloc.state.functions);
    final displaySettings = functionsSettings.display;
    final clockType = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.clockType);
    final calendarDayColor = context
        .select((MemoplannerSettingsBloc bloc) => bloc.state.calendar.dayColor);
    final weekday =
        context.select((ClockCubit currentTime) => currentTime.state.weekday);
    final theme = weekdayTheme(
      dayColor: calendarDayColor,
      languageCode: Localizations.localeOf(context).languageCode,
      weekday: weekday,
    );

    return Theme(
      data: theme.theme,
      child: WillPopScope(
        onWillPop: () async {
          final index = displaySettings.menu ? displaySettings.menuTabIndex : 0;
          DefaultTabController.of(context).index = index;
          return false;
        },
        child: Scaffold(
          appBar: const PhotoCalendarAppBar(),
          backgroundColor: theme.color,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: photoCalendarLayout.clockRowHeight,
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (clockType != ClockType.digital)
                            SizedBox(
                              height: photoCalendarLayout.analogClockSize +
                                  layout.clock.borderWidth * 2,
                              width: photoCalendarLayout.analogClockSize,
                              child: const FittedBox(child: AnalogClock()),
                            ),
                          if (clockType == ClockType.analogueDigital)
                            SizedBox(width: photoCalendarLayout.clockDistance),
                          if (clockType != ClockType.analogue)
                            DigitalClock(
                              style: photoCalendarLayout.textStyle(clockType),
                            ),
                        ],
                      ).pad(
                        clockType == ClockType.digital
                            ? photoCalendarLayout.digitalClockPadding
                            : photoCalendarLayout.analogClockPadding,
                      ),
                      Positioned(
                        bottom: photoCalendarLayout.backButtonPosition.dy,
                        right: photoCalendarLayout.backButtonPosition.dx,
                        child: IconActionButton(
                          style: theme.isLight
                              ? actionButtonStyleLight
                              : actionButtonStyleDark,
                          onPressed: () {
                            final index = functionsSettings.startView ==
                                    StartView.photoAlbum
                                ? 0
                                : functionsSettings.startViewIndex;
                            DefaultTabController.of(context).index = index;
                          },
                          child: Icon(functionsSettings.startView.icon),
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
      ),
    );
  }
}

extension StartViewExtension on StartView {
  IconData get icon {
    switch (this) {
      case StartView.weekCalendar:
        return AbiliaIcons.week;
      case StartView.monthCalendar:
        return AbiliaIcons.month;
      case StartView.menu:
        return AbiliaIcons.appMenu;
      default:
        return AbiliaIcons.day;
    }
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
    final settings = context.watch<MemoplannerSettingsBloc>().state;
    final time = context.watch<ClockCubit>().state;
    return CalendarAppBar(
      textStyle: Theme.of(context).textTheme.headlineMedium,
      day: time.onlyDays(),
      calendarDayColor: settings.calendar.dayColor,
      rows: AppBarTitleRows.day(
        settings: settings.dayAppBar,
        currentTime: time,
        day: time.onlyDays(),
        dayPart: context.read<DayPartCubit>().state,
        dayParts: settings.calendar.dayParts,
        langCode: Localizations.localeOf(context).toLanguageTag(),
        translate: Lt.of(context),
        compactDay: false,
      ),
      showClock: false,
    );
  }
}
