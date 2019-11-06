import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';

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
                    Text(DateFormat('yQQQQ', langCode).format(state)),
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
                  if (!followsNow(state))
                    ActionButton(
                      child: Icon(AbiliaIcons.reset),
                      onPressed: () => jumpToNow(state),
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

  followsNow(DateTime otherTime) =>
      isAtTheSameDayAsNow(otherTime) && currentActivityVisible;

  isAtTheSameDayAsNow(DateTime otherTime) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).isAtSameMomentAs(
        DateTime(otherTime.year, otherTime.month, otherTime.day));
  }

  jumpToNow(DateTime otherTime) {
    if (!isAtTheSameDayAsNow(otherTime)) {
      _dayPickerBloc.add(CurrentDay());
    } else {
      _scrollController.animateTo(cardHeight * indexOfFirstNoneCompleted,
          curve: Curves.fastLinearToSlowEaseIn,
          duration: Duration(milliseconds: 300));
    }
  }

  Widget agendaView() {
    return BlocBuilder<ActivitiesOccasionBloc, ActivitiesOccasionState>(
      builder: (context, state) {
        if (state is! ActivitiesOccasionLoaded) {
          return Center(child: CircularProgressIndicator());
        }
        final activities = (state as ActivitiesOccasionLoaded).activityStates;
        indexOfFirstNoneCompleted =
            activities.indexWhere((a) => a.occasion != Occasion.past);
        return RefreshIndicator(
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: Scrollbar(
                child: ListView.builder(
                  itemExtent: cardHeight,
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
          onRefresh: _refresh,
        );
      },
    );
  }

  Future<void> _refresh() {
    _activitiesBloc.add(LoadActivities());
    return _activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
  }

  bool _onScrollNotification(ScrollNotification scrollNotification) {
    final renderObject = currentActivityKey.currentContext?.findRenderObject();
    bool isVisibleNow = _isRenderObjectVisible(renderObject,
        scrollPosition: scrollNotification.metrics.pixels);
    if (isVisibleNow != currentActivityVisible)
      setState(() => currentActivityVisible = isVisibleNow);
    return false;
  }

  bool _isRenderObjectVisible(RenderObject renderObject,
      {double scrollPosition}) {
    if (renderObject == null)
      return false; // the object is not rendered yet, and is therefore not visible
    RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return false;
    final offsetToRevealBottom =
        viewport.getOffsetToReveal(renderObject, 1.0).offset;
    final offsetToRevealTop =
        viewport.getOffsetToReveal(renderObject, 0.0).offset;
    return scrollPosition > offsetToRevealBottom &&
        scrollPosition < offsetToRevealTop;
  }
}
