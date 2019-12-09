import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';
import 'package:seagull/ui/theme.dart';
import 'package:intl/intl.dart';
import 'package:seagull/utils.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final currentActivityKey = GlobalKey<State>();
  final cardHeight = 80.0;

  DayPickerBloc _dayPickerBloc;
  ScrollController _scrollController;

  @override
  void initState() {
    _dayPickerBloc = BlocProvider.of<DayPickerBloc>(context);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Locale.cachedLocale.languageCode;
    return BlocProvider<ScrollPositionBloc>(
      builder: (context) => ScrollPositionBloc(
          BlocProvider.of<ActivitiesOccasionBloc>(context),
          BlocProvider.of<ClockBloc>(context),
          _dayPickerBloc,
          _scrollController,
          cardHeight,
          currentActivityKey),
      child: BlocBuilder<ClockBloc, DateTime>(
        builder: (context, now) => BlocBuilder<DayPickerBloc, DateTime>(
          builder: (context, pickedDay) => AnimatedTheme(
            data: weekDayTheme(context)[pickedDay.weekday],
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
                        Text(DateFormat('EEEE, d MMM', langCode)
                            .format(pickedDay)),
                        Opacity(
                          opacity: 0.7,
                          child: Text(
                              '${Translator.of(context).translate.week} ${getWeekNumber(pickedDay)}'),
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
              body: Agenda(
                  cardHeight: cardHeight,
                  scrollController: _scrollController,
                  currentActivityKey: currentActivityKey),
              bottomNavigationBar: BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      BlocBuilder<ActivitiesOccasionBloc,
                          ActivitiesOccasionState>(
                        builder: (context, state) => (state
                                is ActivitiesOccasionLoaded)
                            ? GoToNowButton(
                                onDayPressed: () => _scrollToActivity(
                                    _scrollController,
                                    state.indexOfCurrentActivity * cardHeight),
                                onOtherDayPressed: () => _jumpToNow(
                                    _scrollController, _dayPickerBloc, context),
                              )
                            : const SizedBox(width: 48),
                      ),
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
        ),
      ),
    );
  }

  void _jumpToNow(ScrollController scrollController,
      DayPickerBloc dayPickerBloc, BuildContext context) async {
    dayPickerBloc.add(CurrentDay());

    final todayState = await BlocProvider.of<ActivitiesOccasionBloc>(context)
        .cast<ActivitiesOccasionLoaded>()
        .firstWhere((aol) => isAtSameDay(aol.day, dayPickerBloc.initialState));

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActivity(
        scrollController, todayState.indexOfCurrentActivity * cardHeight));
  }

  void _scrollToActivity(
      ScrollController scrollController, double offsetToNow) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
          min(scrollController.position.maxScrollExtent, offsetToNow),
          curve: Curves.easeInOutCirc,
          duration: const Duration(milliseconds: 200));
    }
  }
}
