import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class Agenda extends StatefulWidget {
  final EventsState eventState;

  const Agenda({
    Key? key,
    required this.eventState,
  }) : super(key: key);

  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> with CalendarStateMixin {
  var scrollController = ScrollController(
    initialScrollOffset: 0,
    keepScrollOffset: false,
  );

  @override
  void initState() {
    if (widget.eventState.isToday) {
      if (widget.eventState
          .pastEvents(context.read<ClockBloc>().state)
          .isNotEmpty) {
        scrollController = ScrollController(
          initialScrollOffset: -layout.agenda.topPadding,
          keepScrollOffset: false,
        );
      }
    }

    _addScrollViewRenderCompleteCallback();
    super.initState();
  }

  @override
  void didUpdateWidget(Agenda oldWidget) {
    super.didUpdateWidget(oldWidget);
    _addScrollViewRenderCompleteCallback();
  }

  void _addScrollViewRenderCompleteCallback() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      BlocProvider.of<ScrollPositionCubit>(context)
          .scrollViewRenderComplete(scrollController);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.eventState;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final categoryLabelWidth =
            (boxConstraints.maxWidth - layout.timepillar.width) / 2;
        return RefreshIndicator(
          onRefresh: refresh,
          child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
            buildWhen: (previous, current) =>
                previous.showCategories != current.showCategories,
            builder: (context, memoplannerSettingsState) => Stack(
              children: <Widget>[
                NotificationListener<ScrollNotification>(
                  onNotification: state.isToday ? onScrollNotification : null,
                  child: AbiliaScrollBar(
                    controller: scrollController,
                    child: EventList(
                      scrollController: scrollController,
                      bottomPadding: layout.agenda.bottomPadding,
                      topPadding: layout.agenda.topPadding,
                    ),
                  ),
                ),
                if (memoplannerSettingsState.showCategories) ...[
                  LeftCategory(maxWidth: categoryLabelWidth),
                  RightCategory(maxWidth: categoryLabelWidth),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class EventList extends StatelessWidget {
  final center = GlobalKey();

  EventList({
    Key? key,
    this.scrollController,
    required this.bottomPadding,
    required this.topPadding,
  }) : super(key: key);

  final ScrollController? scrollController;

  final double bottomPadding, topPadding;

  @override
  Widget build(BuildContext context) {
    final sc = scrollController ?? ScrollController();
    return ScrollArrows.vertical(
      upCollapseMargin: topPadding,
      downCollapseMargin: bottomPadding,
      controller: sc,
      child: Builder(builder: (context) {
        final eventState = context.watch<DayEventsCubit>().state;
        final now = context.watch<ClockBloc>().state;
        final dayPartsSetting = context
            .select((MemoplannerSettingBloc bloc) => bloc.state.dayParts);

        final isNight = eventState.day.isAtSameDay(now) &&
            now.dayPart(dayPartsSetting) == DayPart.night;
        final pastEvents = eventState.pastEvents(now);
        final notPastEvents = eventState.notPastEvents(now);
        final isTodayAndNoPast = eventState.isToday && pastEvents.isEmpty;
        return Container(
          key: TestKey.calendarBackgroundColor,
          color: isNight ? TimepillarCalendar.nightBackgroundColor : null,
          child: CustomScrollView(
            center: eventState.isToday ? center : null,
            controller: sc,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (eventState.events.isEmpty &&
                  eventState.fullDayActivities.isEmpty)
                SliverNoActivities(key: center)
              else ...[
                if (!isTodayAndNoPast)
                  SliverPadding(
                    padding: EdgeInsets.only(top: topPadding),
                    sliver: SliverEventList(
                      pastEvents,
                      eventState.day,
                      reversed: eventState.isToday,
                      lastMargin: _lastPastPadding(
                        pastEvents,
                        notPastEvents,
                      ),
                    ),
                  ),
                SliverPadding(
                  key: center,
                  padding: EdgeInsets.only(
                    top: isTodayAndNoPast ? topPadding : 0.0,
                    bottom: bottomPadding,
                  ),
                  sliver: SliverEventList(notPastEvents, eventState.day),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  double _lastPastPadding(
    List<Event> notPastActivities,
    List<Event> pastActivities,
  ) =>
      pastActivities.isEmpty || notPastActivities.isEmpty
          ? 0.0
          : pastActivities.first.category == notPastActivities.first.category
              ? layout.eventCard.marginSmall
              : layout.eventCard.marginLarge;
}

class SliverNoActivities extends StatelessWidget {
  const SliverNoActivities({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(top: layout.agenda.sliverTopPadding),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: Tts(
            child: Text(
              Translator.of(context).translate.noActivities,
              style: abiliaTextTheme.bodyText1
                  ?.copyWith(color: AbiliaColors.black75),
            ),
          ),
        ),
      ),
    );
  }
}

class SliverEventList extends StatelessWidget {
  final List<EventOccasion> events;

  // Reversed because slivers before center are called in reverse order
  final bool reversed;
  final double lastMargin;
  final int _maxIndex;
  final DateTime day;

  const SliverEventList(
    this.events,
    this.day, {
    this.reversed = false,
    this.lastMargin = 0.0,
    Key? key,
  })  : _maxIndex = events.length - 1,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: layout.templates.m1.onlyHorizontal,
      sliver: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.showCategories != current.showCategories ||
            previous.showCategoryColor != current.showCategoryColor,
        builder: (context, setting) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (reversed) index = _maxIndex - index;
                final event = events[index];
                final padding = setting.showCategories
                    ? _padding(index)
                    : EdgeInsets.only(bottom: layout.eventCard.marginSmall);
                if (event is ActivityOccasion) {
                  return Padding(
                    padding: padding,
                    child: ActivityCard(
                      activityOccasion: event,
                      showCategoryColor: setting.showCategoryColor,
                      opacityOnDark: true,
                    ),
                  );
                } else if (event is TimerOccasion) {
                  return Padding(
                    padding: padding,
                    child: TimerCard(
                      timerOccasion: event,
                      day: day,
                    ),
                  );
                }
                return null;
              },
              childCount: events.length,
            ),
          );
        },
      ),
    );
  }

  EdgeInsets _padding(int index) {
    final category = events[index].category;
    return EdgeInsets.only(
      left:
          category != Category.right ? 0 : layout.eventCard.categorySideOffset,
      right:
          category == Category.right ? 0 : layout.eventCard.categorySideOffset,
      bottom: index >= _maxIndex
          ? lastMargin
          : category == events[index + 1].category
              ? layout.eventCard.marginSmall
              : layout.eventCard.marginLarge,
    );
  }
}
