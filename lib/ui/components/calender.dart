import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';
import 'package:seagull/utils/datetime_utils.dart';

class Calender extends StatefulWidget {
  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  final currentActivityKey = GlobalKey<State>();
  final cardHeight = 80.0;
  DayPickerBloc _dayPickerBloc;
  ActivitiesBloc _activitiesBloc;
  ScrollController _scrollController;
  bool currentActivityVisible = false;
  int indexOfFirstNoneCompleted;
  double get offsetToFirstNoneCompleted =>
      cardHeight * indexOfFirstNoneCompleted;
  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _activitiesBloc = BlocProvider.of<ActivitiesBloc>(context);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Locale.cachedLocale.languageCode;
    return BlocBuilder<DayPickerBloc, DateTime>(
      builder: (context, state) => Theme(
        data: weekDayTheme(context)[state.weekday],
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ActionButton(
                  child: Icon(AbiliaIcons.return_to_previous_page),
                  onPressed: () => _dayPickerBloc.add(PreviousDay()),
                ),
                Column(
                  children: [
                    Text(DateFormat('EEEE, d MMM', langCode).format(state)),
                    Opacity(
                      opacity: 0.7,
                      child: Text('${Translator.of(context).translate.week} ${getWeekNumber(state)}'),
                    ),
                  ],
                ),
                ActionButton(
                  child: Icon(AbiliaIcons.go_to_next_page),
                  onPressed: () => _dayPickerBloc.add(NextDay()),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: agendaView(),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (!_followsNow(state))
                    ActionButton(
                      child: Icon(AbiliaIcons.reset),
                      onPressed: () => _jumpToNow(state),
                      themeData: nowButtonTheme(context),
                    )
                  else
                    const SizedBox(width: 48),
                  ActionButton(
                    child: Icon(AbiliaIcons.menu),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LogoutPage()),
                    ),
                    themeData: menuButtonTheme(context),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget agendaView() {
    return BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
      builder: (context, state) {
        if (state is! ActivitiesOccasionLoaded) {
          return Center(child: CircularProgressIndicator());
        }
        final activities = (state as ActivitiesOccasionLoaded).activities;
        final fullDayActivities =
            (state as ActivitiesOccasionLoaded).fullDayActivities;
        indexOfFirstNoneCompleted =
            activities.indexWhere((a) => a.occasion != Occasion.past);
            indexOfFirstNoneCompleted = indexOfFirstNoneCompleted < 0 ? activities.length - 1 : indexOfFirstNoneCompleted;
        return BlocListener<ClockBloc, DateTime>(
          listener: (context, now) {
            if (_followsNow(now))
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToNow());
          },
          child: Column(
            children: <Widget>[
              if (fullDayActivities.isNotEmpty)
                Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).appBarTheme.color),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      children: fullDayActivities
                          .map((ao) => ActivityCard(
                              activityOccasion: ao, height: cardHeight))
                          .toList(),
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _isAtTheSameDayAsNow(state.now)
                          ? _onScrollNotification
                          : null,
                      child: Scrollbar(
                        child: ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(), // https://github.com/flutter/flutter/issues/22180
                          itemExtent: cardHeight,
                          controller: _isAtTheSameDayAsNow(state.now)
                              ? _scrollController
                              : null,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          itemCount: activities.length,
                          itemBuilder: (context, index) => ActivityCard(
                            activityOccasion: activities[index],
                            height: cardHeight,
                            key: index == indexOfFirstNoneCompleted
                                ? currentActivityKey
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _followsNow(DateTime otherTime) {
    final sameDay = _isAtTheSameDayAsNow(otherTime);
    return sameDay && currentActivityVisible;
  }

  _isAtTheSameDayAsNow(DateTime otherTime) =>
      isAtSameDay(otherTime, DateTime.now());

  _jumpToNow(DateTime otherTime) {
    if (!_isAtTheSameDayAsNow(otherTime))
      _dayPickerBloc.add(CurrentDay());
    else
      _scrollToNow();
  }

  _scrollToNow(
          {Curve curve = Curves.fastLinearToSlowEaseIn,
          Duration duration = const Duration(milliseconds: 300)}) =>
      _scrollController.animateTo(offsetToFirstNoneCompleted,
          curve: curve, duration: duration);

  Future<void> _refresh() {
    _activitiesBloc..add(LoadActivities());
    return _activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
  }

  bool _onScrollNotification(ScrollNotification scrollNotification) =>
      _setcurrentActivityVisible(
          scrollPosition: scrollNotification.metrics.pixels) ==
      true;

  _setcurrentActivityVisible({@required double scrollPosition}) {
    final bool isVisibleNow = _isActivityInView(scrollPosition: scrollPosition);
    if (isVisibleNow != currentActivityVisible) {
      print('current activity came ${isVisibleNow ? 'into' : 'out of'} view');
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => currentActivityVisible = isVisibleNow));
    }
  }

  bool _isActivityInView({@required double scrollPosition}) {
    final RenderObject renderObject =
        currentActivityKey.currentContext?.findRenderObject();
    return renderObject != null &&
        _isRenderObjectVisible(renderObject, scrollPosition: scrollPosition);
  }

  bool _isRenderObjectVisible(RenderObject renderObject,
      {@required double scrollPosition}) {
    if (renderObject == null) return false;
    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return false;
    final double offsetToRevealBottom =
        viewport.getOffsetToReveal(renderObject, 1.0).offset;
    final double offsetToRevealTop =
        viewport.getOffsetToReveal(renderObject, 0.0).offset;
    return scrollPosition > offsetToRevealBottom &&
        scrollPosition < offsetToRevealTop;
  }
}
