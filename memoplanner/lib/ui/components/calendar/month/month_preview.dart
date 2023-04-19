import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class MonthListPreview extends StatelessWidget {
  final List<DayTheme> dayThemes;

  const MonthListPreview({
    required this.dayThemes,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthPreviewLayout = layout.monthCalendar.monthPreview;
    final dayPickerState = context.watch<DayPickerBloc>().state;
    final monthCalendarState = context.watch<MonthCalendarCubit>().state;
    final isCollapsed = monthCalendarState.isCollapsed;
    final showPreview =
        monthCalendarState.firstDay.month == dayPickerState.day.month &&
            monthCalendarState.firstDay.year == dayPickerState.day.year;
    if (!showPreview) {
      return isCollapsed
          ? SizedBox(
              height: monthPreviewLayout.headingHeight +
                  monthPreviewLayout.monthListPreviewPadding.vertical,
            )
          : Padding(
              padding: monthPreviewLayout.noSelectedDayPadding,
              child: Text(
                Translator.of(context).translate.selectADayToViewDetails,
                style: abiliaTextTheme.bodyLarge,
              ),
            );
    }
    final dayTheme = dayThemes[dayPickerState.day.weekday - 1];
    return Padding(
      padding: monthPreviewLayout.monthListPreviewPadding,
      child: Column(
        children: [
          AnimatedTheme(
            data: dayTheme.theme,
            child: MonthDayPreviewHeading(
              day: dayPickerState.day,
              isLight: dayTheme.isLight,
              occasion: dayPickerState.occasion,
              isCollapsed: isCollapsed,
            ),
          ),
          if (!isCollapsed) const Expanded(child: MonthPreview()),
        ],
      ),
    );
  }
}

class MonthPreview extends StatefulWidget {
  const MonthPreview({super.key});

  @override
  State<MonthPreview> createState() => _MonthPreviewState();
}

class _MonthPreviewState extends State<MonthPreview> {
  late final controller = ScrollController(
    initialScrollOffset:
        -layout.monthCalendar.monthPreview.activityListTopPadding,
  );

  @override
  void didUpdateWidget(covariant MonthPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final jumpTo =
          (-layout.monthCalendar.monthPreview.activityListTopPadding).clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );
      controller.jumpTo(jumpTo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: layout.monthCalendar.monthPreview.monthPreviewBorderWidth,
      ),
      decoration: const BoxDecoration(color: AbiliaColors.transparentBlack30),
      child: Container(
        decoration: const BoxDecoration(color: AbiliaColors.white),
        child: EventList(
          scrollController: controller,
          topPadding: layout.monthCalendar.monthPreview.activityListTopPadding,
          bottomPadding:
              layout.monthCalendar.monthPreview.activityListBottomPadding,
          events: context.watch<DayEventsCubit>().state,
          centerNoActivitiesText: true,
        ),
      ),
    );
  }
}

class MonthDayPreviewHeading extends StatelessWidget {
  const MonthDayPreviewHeading({
    required this.day,
    required this.isLight,
    required this.occasion,
    required this.isCollapsed,
    super.key,
  });

  final DateTime day;
  final bool isLight;
  final Occasion occasion;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    final dateText =
        DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
            .format(day);
    final previewLayout = layout.monthCalendar.monthPreview;
    return Tts.data(
      data: dateText,
      child: GestureDetector(
        onTap: () => DefaultTabController.of(context).animateTo(0),
        child: Container(
          padding: previewLayout.headingPadding,
          height: previewLayout.headingHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: radius),
            color: Theme.of(context).appBarTheme.backgroundColor,
          ),
          child: BlocBuilder<DayEventsCubit, EventsState>(
            builder: (context, eventState) {
              if (eventState is EventsLoading) return const SizedBox.shrink();
              final fullDayActivities = eventState.fullDayActivities.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: (fullDayActivities > 0)
                          ? CrossOver(
                              style: CrossOverStyle.darkSecondary,
                              applyCross: occasion.isPast,
                              padding: previewLayout.crossOverPadding,
                              child: (fullDayActivities > 1)
                                  ? ClickableFullDayStack(
                                      fullDayActivitiesBuilder: (context) =>
                                          context.select(
                                              (DayEventsCubit cubit) => cubit
                                                  .state.fullDayActivities),
                                      key: TestKey
                                          .monthPreviewHeaderFullDayStack,
                                      numberOfActivities:
                                          eventState.fullDayActivities.length,
                                      width: previewLayout
                                          .headingFullDayActivityWidth,
                                      height: previewLayout
                                          .headingFullDayActivityHeight,
                                      day: eventState.day,
                                    )
                                  : MonthActivityContent(
                                      key: TestKey.monthPreviewHeaderActivity,
                                      activityDay:
                                          eventState.fullDayActivities.first,
                                      isPast: eventState
                                          .fullDayActivities.first.isPast,
                                      width: previewLayout
                                          .headingFullDayActivityWidth,
                                      height: previewLayout
                                          .headingFullDayActivityHeight,
                                      goToActivityOnTap: true,
                                    ),
                            )
                          : null,
                    ),
                  ),
                  CrossOver(
                    style: isLight
                        ? CrossOverStyle.lightDefault
                        : CrossOverStyle.darkDefault,
                    applyCross: occasion.isPast,
                    fallbackHeight: previewLayout.dateTextCrossOverSize.height,
                    child: Center(
                      child: Text(
                        dateText,
                        style: Theme.of(context).textTheme.titleMedium,
                        key: TestKey.monthPreviewHeaderTitle,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (layout.go)
                    SizedBox(
                      height: previewLayout.headingFullDayActivityWidth,
                      width: previewLayout.headingFullDayActivityWidth,
                      child: IconActionButton(
                        onPressed: () async =>
                            context.read<MonthCalendarCubit>().togglePreview(),
                        style: isLight
                            ? actionButtonStyleLight
                            : actionButtonStyleDark,
                        child: Icon(
                          isCollapsed
                              ? AbiliaIcons.navigationUp
                              : AbiliaIcons.navigationDown,
                          size: previewLayout.headingButtonIconSize,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
