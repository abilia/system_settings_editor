import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/all.dart';

class Agenda extends StatefulWidget {
  static final topPadding = 60.0.s, bottomPadding = 125.0.s;

  final EventsLoaded eventState;
  final DateTime now;

  const Agenda({
    Key? key,
    required this.eventState,
    required this.now,
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
          initialScrollOffset: -Agenda.topPadding,
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
      BlocProvider.of<ScrollPositionBloc>(context)
          .add(ScrollViewRenderComplete(scrollController));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.eventState;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final categoryLabelWidth =
            (boxConstraints.maxWidth - defaultTimePillarWidth) / 2;
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
                    child: ActivityList(
                      state: state,
                      scrollController: scrollController,
                      bottomPadding: Agenda.bottomPadding,
                      topPadding: Agenda.topPadding,
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

class ActivityList extends StatelessWidget {
  final center = GlobalKey();

  ActivityList({
    Key? key,
    required this.state,
    this.scrollController,
    required this.bottomPadding,
    required this.topPadding,
  }) : super(key: key);

  final EventsLoaded state;

  final ScrollController? scrollController;

  final double bottomPadding, topPadding;

  @override
  Widget build(BuildContext context) {
    final sc = scrollController ?? ScrollController();
    return ScrollArrows.vertical(
      upCollapseMargin: topPadding,
      downCollapseMargin: bottomPadding,
      controller: sc,
      child: BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) {
          final pastEvents = state.pastEvents(now);
          final notPastEvents = state.notPastEvents(now);
          final isTodayAndNoPast = state.isToday && pastEvents.isEmpty;
          return CustomScrollView(
            center: state.isToday ? center : null,
            controller: sc,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state.events.isEmpty && state.fullDayActivities.isEmpty)
                SliverNoActivities(key: center)
              else ...[
                if (!isTodayAndNoPast)
                  SliverPadding(
                    padding: EdgeInsets.only(top: topPadding),
                    sliver: SliverActivityList(
                      state.pastEvents(now),
                      state.occasion,
                      reversed: state.isToday,
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
                  sliver: SliverActivityList(
                    notPastEvents,
                    state.occasion,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  double _lastPastPadding(
    List<EventDay> notPastActivities,
    List<EventDay> pastActivities,
  ) =>
      pastActivities.isEmpty || notPastActivities.isEmpty
          ? 0.0
          : pastActivities.first.event.category ==
                  notPastActivities.first.event.category
              ? ActivityCard.cardMarginSmall
              : ActivityCard.cardMarginLarge;
}

class SliverNoActivities extends StatelessWidget {
  const SliverNoActivities({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(top: 96.s),
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

class SliverActivityList extends StatelessWidget {
  final List<EventOccasion> events;
  final Occasion dayOccasion;
  // Reversed because slivers before center are called in reverse order
  final bool reversed;
  final double lastMargin;
  final int _maxIndex;

  const SliverActivityList(
    this.events,
    this.dayOccasion, {
    this.reversed = false,
    this.lastMargin = 0.0,
    Key? key,
  })  : _maxIndex = events.length - 1,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 12.0.s),
      sliver: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.showCategories != current.showCategories ||
            previous.showCategoryColor != current.showCategoryColor,
        builder: (context, setting) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (reversed) index = _maxIndex - index;
                final eventDay = events[index];
                final padding = setting.showCategories
                    ? _padding(index)
                    : EdgeInsets.only(bottom: ActivityCard.cardMarginSmall);
                if (eventDay is ActivityOccasion) {
                  return Padding(
                    padding: padding,
                    child: ActivityCard(
                      activityOccasion: eventDay,
                      showCategoryColor: setting.showCategoryColor,
                    ),
                  );
                } else if (eventDay is TimerOccasion) {
                  return Padding(
                    padding: padding,
                    child: TimerCard(timerOccasion: eventDay),
                  );
                }
              },
              childCount: events.length,
            ),
          );
        },
      ),
    );
  }

  EdgeInsets _padding(int index) {
    final category = events[index].event.category;
    return EdgeInsets.only(
      left: category != Category.right ? 0 : ActivityCard.categorySideOffset,
      right: category == Category.right ? 0 : ActivityCard.categorySideOffset,
      bottom: index >= _maxIndex
          ? lastMargin
          : category == events[index + 1].event.category
              ? ActivityCard.cardMarginSmall
              : ActivityCard.cardMarginLarge,
    );
  }
}
