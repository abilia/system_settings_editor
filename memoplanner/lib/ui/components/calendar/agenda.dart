import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class Agenda extends StatelessWidget with CalendarWidgetMixin {
  final EventsState eventsState;

  const Agenda({
    required this.eventsState,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = context.select(
      (MemoplannerSettingsBloc bloc) => bloc.state.calendar.categories.show
          ? layout.templates.l3
          : layout.templates.s2,
    );
    return RefreshIndicator(
      onRefresh: () async => refresh(context),
      child: Stack(
        children: <Widget>[
          CalendarScrollListener(
            getNowOffset: (_) => -padding.top,
            enabled: eventsState.isToday,
            agendaEvents: eventsState.events.length +
                eventsState.fullDayActivities.length,
            builder: (_, verticalController, __) {
              return AbiliaScrollBar(
                controller: verticalController,
                child: EventList(
                  scrollController: verticalController,
                  topPadding: padding.top,
                  bottomPadding: padding.bottom,
                  events: eventsState,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EventList extends StatelessWidget {
  final center = GlobalKey();

  EventList({
    required this.bottomPadding,
    required this.topPadding,
    required this.events,
    required this.scrollController,
    this.centerNoActivitiesText = false,
    Key? key,
  }) : super(key: key);

  final ScrollController? scrollController;
  final double bottomPadding, topPadding;
  final EventsState events;
  final bool centerNoActivitiesText;

  @override
  Widget build(BuildContext context) {
    return ScrollArrows.vertical(
      upCollapseMargin: topPadding,
      downCollapseMargin: bottomPadding,
      controller: scrollController,
      child: Builder(builder: (context) {
        final now = context.watch<ClockBloc>().state;

        final todayNight = context.watch<NightMode>().state;
        final pastEvents = events.pastEvents(now);
        final notPastEvents = events.notPastEvents(now);
        final isTodayAndNoPast = events.isToday && pastEvents.isEmpty;
        return Container(
          key: TestKey.calendarBackgroundColor,
          color: todayNight ? nightBackgroundColor : null,
          child: CustomScrollView(
            center: events.isToday ? center : null,
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (events.events.isEmpty && events.fullDayActivities.isEmpty)
                SliverNoActivities(
                  key: center,
                  center: centerNoActivitiesText,
                )
              else ...[
                SliverPadding(
                  padding: EdgeInsets.only(top: topPadding),
                  sliver: isTodayAndNoPast
                      ? null
                      : SliverEventList(
                          pastEvents,
                          events.day,
                          reversed: events.isToday,
                          lastMargin: _lastPastPadding(
                            pastEvents,
                            notPastEvents,
                          ),
                          isNight: todayNight,
                        ),
                ),
                SliverEventList(
                  notPastEvents,
                  events.day,
                  isNight: todayNight,
                  lastMargin: layout.eventCard.marginSmall,
                  key: center,
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
  const SliverNoActivities({required this.center, Key? key}) : super(key: key);
  final bool center;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Align(
        alignment: center ? Alignment.center : Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(
            top: center ? 0 : layout.templates.l3.top,
          ),
          child: Tts(
            child: Text(
              Lt.of(context).noActivities,
              style: abiliaTextTheme.bodyLarge
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
  final bool isNight;

  const SliverEventList(
    this.events,
    this.day, {
    this.reversed = false,
    this.isNight = false,
    this.lastMargin = 0.0,
    Key? key,
  })  : _maxIndex = events.length - 1,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoriesSettings = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.categories);
    return SliverPadding(
      padding: layout.templates.m1.onlyHorizontal,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (reversed) index = _maxIndex - index;
            final event = events[index];
            final padding = categoriesSettings.show
                ? _padding(index)
                : EdgeInsets.only(bottom: layout.eventCard.marginSmall);
            if (event is ActivityOccasion) {
              return Padding(
                padding: padding,
                child: ActivityCard(
                  activityOccasion: event,
                  showCategoryColor: categoriesSettings.showColors,
                  useOpacity: isNight,
                ),
              );
            } else if (event is TimerOccasion) {
              return Padding(
                padding: padding,
                child: TimerCard(
                  timerOccasion: event,
                  day: day,
                  useOpacity: isNight,
                ),
              );
            }
            return null;
          },
          childCount: events.length,
        ),
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
