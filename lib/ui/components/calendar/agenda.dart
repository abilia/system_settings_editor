import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class Agenda extends StatelessWidget with CalendarWidgetMixin {
  final EventsState eventsState;

  const Agenda({
    required this.eventsState,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => refresh(context),
      child: Stack(
        children: <Widget>[
          ScrollListener(
            getNowOffset: (_) => -layout.agenda.topPadding,
            inViewMargin: layout.eventCard.height / 2,
            enabled: eventsState.isToday,
            builder: (_, controller) {
              return AbiliaScrollBar(
                controller: controller,
                child: EventList(
                  scrollController: controller,
                  bottomPadding: layout.agenda.bottomPadding,
                  topPadding: layout.agenda.topPadding,
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
    Key? key,
  }) : super(key: key);

  final ScrollController? scrollController;
  final double bottomPadding, topPadding;
  final EventsState events;

  @override
  Widget build(BuildContext context) {
    return ScrollArrows.vertical(
      upCollapseMargin: topPadding,
      downCollapseMargin: bottomPadding,
      controller: scrollController,
      child: Builder(builder: (context) {
        final now = context.watch<ClockBloc>().state;

        final todayNight = events.day.isAtSameDay(now) &&
            context.read<DayPartCubit>().state.isNight;
        final pastEvents = events.pastEvents(now);
        final notPastEvents = events.notPastEvents(now);
        final isTodayAndNoPast = events.isToday && pastEvents.isEmpty;
        return Container(
          key: TestKey.calendarBackgroundColor,
          color: todayNight ? TimepillarCalendar.nightBackgroundColor : null,
          child: CustomScrollView(
            center: events.isToday ? center : null,
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (events.events.isEmpty && events.fullDayActivities.isEmpty)
                SliverNoActivities(key: center)
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
