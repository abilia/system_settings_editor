import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/models/all.dart';

class Agenda extends StatefulWidget {
  static final topPadding = 60.0.s, bottomPadding = 125.0.s;

  final ActivitiesOccasionLoaded activityState;

  const Agenda({
    Key? key,
    required this.activityState,
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
    if (widget.activityState.isToday) {
      if (widget.activityState.pastActivities.isNotEmpty) {
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
    final state = widget.activityState;
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final categoryLabelWidth = (boxConstraints.maxWidth -
                layout.timePillarLayout.defaultTimePillarWidth.s) /
            2;
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

  final ActivitiesOccasionLoaded state;

  final ScrollController? scrollController;

  final double bottomPadding, topPadding;

  @override
  Widget build(BuildContext context) {
    final sc = scrollController ?? ScrollController();
    return ScrollArrows.vertical(
      upCollapseMargin: topPadding,
      downCollapseMargin: bottomPadding,
      controller: sc,
      child: CustomScrollView(
        center: state.isToday ? center : null,
        controller: sc,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (state.activities.isEmpty && state.fullDayActivities.isEmpty)
            SliverNoActivities(key: center)
          else ...[
            if (!state.isTodayAndNoPast)
              SliverPadding(
                padding: EdgeInsets.only(top: topPadding),
                sliver: SliverActivityList(
                  state.pastActivities,
                  reversed: state.isToday,
                  lastMargin: _lastPastPadding(
                    state.pastActivities,
                    state.notPastActivities,
                  ),
                ),
              ),
            SliverPadding(
              key: center,
              padding: EdgeInsets.only(
                top: state.isTodayAndNoPast ? topPadding : 0.0,
                bottom: bottomPadding,
              ),
              sliver: SliverActivityList(
                state.notPastActivities,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _lastPastPadding(
    List<ActivityOccasion> notPastActivities,
    List<ActivityOccasion> pastActivities,
  ) =>
      pastActivities.isEmpty || notPastActivities.isEmpty
          ? 0.0
          : pastActivities.first.activity.category ==
                  notPastActivities.first.activity.category
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
  final List<ActivityOccasion> activities;
  // Reversed because slivers before center are called in reverse order
  final bool reversed;
  final double lastMargin;
  final int _maxIndex;

  const SliverActivityList(
    this.activities, {
    this.reversed = false,
    this.lastMargin = 0.0,
    Key? key,
  })  : _maxIndex = activities.length - 1,
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
                return ActivityCard(
                  activityOccasion: activities[index],
                  bottomPadding: setting.showCategories
                      ? _padding(index)
                      : ActivityCard.cardMarginSmall,
                  showCategories: setting.showCategories,
                  showCategoryColor: setting.showCategoryColor,
                );
              },
              childCount: activities.length,
            ),
          );
        },
      ),
    );
  }

  double _padding(int index) => index >= _maxIndex
      ? lastMargin
      : activities[index].activity.category ==
              activities[index + 1].activity.category
          ? ActivityCard.cardMarginSmall
          : ActivityCard.cardMarginLarge;
}
