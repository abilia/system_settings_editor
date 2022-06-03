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
        fontSize: tempLayout.digitalClockFontSize,
        height: 1,
        fontWeight: tempLayout.digitalClockFontWeight,
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
                height: tempLayout.clockRowHeight,
                color: theme.color,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.clockType != ClockType.digital)
                          SizedBox(
                            height: tempLayout.analogClockSize +
                                layout.clock.borderWidth * 2,
                            width: tempLayout.analogClockSize,
                            child: const FittedBox(child: AnalogClock()),
                          ),
                        if (state.clockType == ClockType.analogueDigital)
                          SizedBox(width: tempLayout.clockDistance),
                        if (state.clockType != ClockType.analogue)
                          DigitalClock(style: style),
                      ],
                    ).pad(
                      state.clockType == ClockType.digital
                          ? tempLayout.digitalClockPadding
                          : tempLayout.analogClockPadding,
                    ),
                    Positioned(
                      bottom: tempLayout.backButtonPosition.dy,
                      right: tempLayout.backButtonPosition.dx,
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

const bool mediumthing = true;

// PhotoCalendar not implemented in MPGO
class TEMPPhotoCalendarLayout {
  final Size appBarSize;
  final EdgeInsets analogClockPadding, digitalClockPadding;
  final double clockDistance,
      clockRowHeight,
      analogClockSize,
      digitalClockFontSize;
  final FontWeight digitalClockFontWeight;
  final Offset backButtonPosition;

  const TEMPPhotoCalendarLayout({
    this.appBarSize = const Size.square(0),
    this.analogClockPadding = EdgeInsets.zero,
    this.digitalClockPadding = EdgeInsets.zero,
    this.clockDistance = 0,
    this.clockRowHeight = 0,
    this.analogClockSize = 0,
    this.backButtonPosition = Offset.zero,
    this.digitalClockFontSize = 0,
    this.digitalClockFontWeight = FontWeight.normal,
  });
}

class MediumPhotoCalendarLayout extends TEMPPhotoCalendarLayout {
  const MediumPhotoCalendarLayout({
    Size? appBarSize,
    EdgeInsets? analogClockPadding,
    EdgeInsets? digitalClockPadding,
    double? clockDistance,
    double? clockRowHeight,
    double? digitalClockFontSize,
    double? analogClockSize,
    FontWeight? digitalClockFontWeight,
    Offset? backButtonPosition,
  }) : super(
          appBarSize: appBarSize ?? const Size.fromHeight(216),
          analogClockPadding:
              analogClockPadding ?? const EdgeInsets.only(top: 3),
          digitalClockPadding:
              digitalClockPadding ?? const EdgeInsets.only(top: 76),
          clockDistance: clockDistance ?? 27,
          clockRowHeight: clockRowHeight ?? 248,
          digitalClockFontSize: digitalClockFontSize ?? 64,
          analogClockSize: analogClockSize ?? 200,
          digitalClockFontWeight: digitalClockFontWeight ?? FontWeight.w400,
          backButtonPosition: backButtonPosition ?? const Offset(24, 32),
        );
}

class LargePhotoCalendarLayout extends MediumPhotoCalendarLayout {
  const LargePhotoCalendarLayout()
      : super(
          clockRowHeight: 384,
          analogClockSize: 320,
          analogClockPadding: const EdgeInsets.only(top: 17),
          digitalClockPadding: const EdgeInsets.only(top: 129),
          clockDistance: 64,
          backButtonPosition: const Offset(24, 24),
          digitalClockFontSize: 112,
          digitalClockFontWeight: FontWeight.w300,
        );
}

final tempLayout = layout.runtimeType == MediumPhotoCalendarLayout
    ? const MediumPhotoCalendarLayout()
    : const LargePhotoCalendarLayout();

class PhotoCalendarAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PhotoCalendarAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => tempLayout.appBarSize;

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
